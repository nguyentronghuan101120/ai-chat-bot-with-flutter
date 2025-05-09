import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:dio/dio.dart';

abstract class ChatRepository {
  Stream<ChatEntity> streamChat({
    required List<ChatEntity> messages,
    String? chatSessionId,
    bool? hasFile,
    required CancelToken cancelToken,
  });

  Future<void> cancelChat({required String chatSessionId});
}
