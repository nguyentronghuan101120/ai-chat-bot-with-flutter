import 'dart:convert';
import 'package:ai_chat_bot/constants/enum.dart';
import 'package:ai_chat_bot/data/data_sources/chat_remote_sources.dart';
import 'package:ai_chat_bot/data/models/requests/cancel_chat_request.dart';
import 'package:ai_chat_bot/data/models/requests/chat_message.dart';
import 'package:ai_chat_bot/data/models/requests/chat_request.dart';
import 'package:ai_chat_bot/data/models/responses/base_response.dart';
import 'package:ai_chat_bot/data/models/responses/chat_response.dart';
import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:ai_chat_bot/domain/repositories/chat_repository.dart';
import 'package:ai_chat_bot/gen/locale_keys.g.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteSources _sources;

  ChatRepositoryImpl(this._sources);

  @override
  Stream<ChatEntity> streamChat({
    required List<ChatEntity> messages,
    bool? hasFile,
    String? chatSessionId,
    required CancelToken cancelToken,
  }) async* {
    final newMessages = messages
        .where((e) =>
            e.role != ChatRole.file &&
            !(e.role == ChatRole.assistant && e.message.isEmpty))
        .map((e) => ChatMessage(role: e.role, content: e.message))
        .toList();

    final ChatRequest request = ChatRequest(
      prompt: newMessages,
      hasFile: hasFile ?? false,
      chatSessionId: chatSessionId,
    );

    final response =
        await _sources.streamChat(request, cancelToken) as ResponseBody;

    final stream = response.stream.map((chunk) => utf8.decode(chunk));

    final accumulatedContentBuffer = StringBuffer();

    await for (final chunk in stream) {
      try {
        // Split the chunk by newlines to handle multiple JSON objects
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.trim().isEmpty) continue;

          // Parse the JSON response
          final jsonMap = json.decode(line) as Map<String, dynamic>;
          final baseResponse = BaseResponse<ChatResponse>.fromJson(
            jsonMap,
            (json) => ChatResponse.fromJson(json as Map<String, dynamic>),
          );

          final choices = baseResponse.data.choices;

          if (choices != null && choices.isNotEmpty) {
            final delta = choices.first.delta;

            if (delta != null && delta.content != null) {
              accumulatedContentBuffer.write(delta.content);
            }

            final chatEntity = ChatEntity(
              role: ChatRole.assistant,
              message: accumulatedContentBuffer.isEmpty
                  ? LocaleKeys.toolCallProcessing.tr()
                  : accumulatedContentBuffer.toString(),
              isLoading: false,
              chatSessionId: chatSessionId ?? baseResponse.data.id,
            );

            yield chatEntity;
          }
        }
      } catch (e) {
        // Skip invalid JSON chunks
        rethrow;
      }
    }
  }

  @override
  Future<void> cancelChat({required String chatSessionId}) async {
    try {
      final CancelChatRequest request =
          CancelChatRequest(chatSessionId: chatSessionId);

      await _sources.cancelChat(request);
    } catch (_) {
      rethrow;
    }
  }
}
