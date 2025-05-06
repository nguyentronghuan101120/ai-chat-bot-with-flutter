import 'dart:convert';
import 'package:ai_chat_bot/constants/enum.dart';
import 'package:ai_chat_bot/data/data_sources/chat_remote_sources.dart';
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
  }) async* {
    final newMessages = messages
        .map((e) => ChatMessage(role: e.role, content: e.message))
        .toList();
    newMessages.removeWhere((e) => e.role == ChatRole.file);

    final ChatRequest request = ChatRequest(
      prompt: newMessages,
      hasFile: hasFile ?? false,
      chatSessionId: chatSessionId,
    );

    final response = await _sources.streamChat(request);

    final stream = response.data.stream.map((chunk) => utf8.decode(chunk));

    String accumulatedContent = '';

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

          final data = baseResponse.data;

          if (data.choices != null && data.choices!.isNotEmpty) {
            final delta = data.choices!.first.delta;
            if (delta != null && delta.content != null) {
              accumulatedContent += delta.content!;
            }

            final chatEntity = ChatEntity(
              role: ChatRole.assistant,
              message: accumulatedContent.isEmpty
                  ? LocaleKeys.toolCallProcessing.tr()
                  : accumulatedContent,
              isLoading: false,
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
}
