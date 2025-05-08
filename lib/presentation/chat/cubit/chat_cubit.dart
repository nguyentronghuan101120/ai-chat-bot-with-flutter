// ignore: unused_import
import 'dart:io';

import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:ai_chat_bot/domain/repositories/chat_repository.dart';
import 'package:ai_chat_bot/domain/repositories/file_repository.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._chatRepository,
    this._fileRepository,
  ) : super(ChatInitial());

  final ChatRepository _chatRepository;
  final FileRepository _fileRepository;

  String? _chatSessionId;

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

    if (files != null) {
      await _uploadFile(
        files: files,
      );
    }

    _chatRepository
        .streamChat(
      messages: chatHistories,
      hasFile: files != null,
      chatSessionId: _chatSessionId,
    )
        .listen(
      (event) async {
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
      onDone: () {
        emit(BotChatGenerateStopped(chatHistories));
      },
      cancelOnError: true,
    );
  }
}
