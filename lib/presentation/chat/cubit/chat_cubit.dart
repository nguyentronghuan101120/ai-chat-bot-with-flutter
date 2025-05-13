// ignore: unused_import
import 'dart:io';
import 'dart:async';

import 'package:ai_chat_bot/constants/enum.dart';
import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:ai_chat_bot/domain/repositories/chat_repository.dart';
import 'package:ai_chat_bot/domain/repositories/file_repository.dart';
import 'package:ai_chat_bot/domain/repositories/local_repository.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._chatRepository,
    this._fileRepository,
    this._localRepository, {
    String? initialChatSessionId,
  }) : super(ChatInitial()) {
    if (initialChatSessionId != null) {
      _loadInitialChat(initialChatSessionId);
    }
  }

  final ChatRepository _chatRepository;
  final FileRepository _fileRepository;
  final LocalRepository _localRepository;

  String? _chatSessionId;
  StreamSubscription<ChatEntity>? _chatStreamSubscription;
  CancelToken _cancelToken = CancelToken();

  void _loadInitialChat(String initialChatSessionId) {
    try {
      final chatHistories =
          _localRepository.getChatHistoryFromLocal(initialChatSessionId);

      _chatSessionId = initialChatSessionId;

        emit(BotChatGenerateStopped(chatHistories));

    } on Exception catch (e) {
      emit(
        ChatError(
          e.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<void> _uploadFile({
    required List<PlatformFile> files,
  }) async {
    for (var file in files) {
      final newChatSessionId = await _fileRepository.uploadAndProcessFile(
        file: file,
        chatSessionId: _chatSessionId,
      );

      _chatSessionId ??= newChatSessionId;
    }
  }

  void sendMessage({
    required List<ChatEntity> chatHistories,
    List<PlatformFile>? files,
    String? chatSessionId,
  }) async {
    emit(InChattingWithBot(chatHistories));

    _cancelToken.cancel();

    if (_cancelToken.isCancelled) {
      _cancelToken = CancelToken();
    }

    if (files != null) {
      await _uploadFile(
        files: files,
      );
    }

    _chatStreamSubscription?.cancel();
    _chatStreamSubscription = _chatRepository
        .streamChat(
      messages: chatHistories,
      hasFile: files != null && files.isNotEmpty,
      chatSessionId: _chatSessionId,
      cancelToken: _cancelToken,
    )
        .listen(
      (event) async {
        _chatSessionId ??= event.chatSessionId;

        final latestMessage = event.message;

        chatHistories.last = chatHistories.last.copyWith(
          message: latestMessage,
          isLoading: event.isLoading,
        );

        emit(BotChatGenerating(List.from(chatHistories)));
      },
      onError: (error) {
        emit(ChatError(error.toString()));

        throw Exception(error);
      },
      onDone: () async {
        await _localRepository.saveChatToLocal(
          chatHistories: chatHistories,
          chatSessionId: _chatSessionId,
          chatSummary:
              chatHistories.firstWhere((e) => e.role == ChatRole.user).message,
        );
        emit(BotChatGenerateStopped(chatHistories));
      },
      cancelOnError: true,
    );
  }

  void stopChat() async {
    if (_chatSessionId != null) {
      try {
        await _chatRepository.cancelChat(chatSessionId: _chatSessionId!);
      } catch (e) {
        emit(ChatError("Failed to cancel chat: $e"));
      }
    }
    _chatStreamSubscription?.cancel();
    _cancelToken.cancel();
    if (state is BotChatGenerating) {
      final currentState = state as BotChatGenerating;
      final messages = List<ChatEntity>.from(currentState.messages);
      if (messages.isNotEmpty && messages.last.role == ChatRole.assistant) {
        messages[messages.length - 1] = messages.last.copyWith(
          hasCanceled: true,
          isLoading: false,
        );
      }
      emit(BotChatGenerateStopped(messages));
    }
  }

  @override
  Future<void> close() {
    _chatStreamSubscription?.cancel();
    return super.close();
  }
}
