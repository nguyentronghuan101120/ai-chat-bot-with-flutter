import 'package:ai_chat_bot/domain/entities/chat_entity.dart';

abstract class ChatRepository {
  Stream<ChatEntity> streamChat(List<ChatEntity> messages);
}
