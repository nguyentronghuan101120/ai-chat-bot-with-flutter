import 'package:ai_chat_bot/constants/enum.dart';
import 'package:ai_chat_bot/constants/hive_type_definition.dart';
import 'package:ai_chat_bot/data/models/local_models/file_info.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'chat_history.g.dart';

@HiveType(typeId: HiveTypeDefinition.chatHistory)
class ChatHistory extends HiveObject {
  @HiveField(0)
  final String message;
  @HiveField(1)
  final ChatRole role;
  @HiveField(2)
  final List<FileInfo>? files;

  ChatHistory({
    required this.message,
    required this.role,
    this.files,
  });
}
