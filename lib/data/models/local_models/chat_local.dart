import 'package:ai_chat_bot/constants/hive_type_definition.dart';
import 'package:ai_chat_bot/data/models/local_models/chat_history.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'chat_local.g.dart';

@HiveType(typeId: HiveTypeDefinition.chatLocal)
class ChatLocal extends HiveObject {
  @HiveField(0)
  final String? chatSessionId;
  @HiveField(1)
  final List<ChatHistory> chatHistories;
  @HiveField(2)
  final String? chatSummary;

  ChatLocal({
    this.chatSessionId,
    required this.chatHistories,
    this.chatSummary,
  });
}
