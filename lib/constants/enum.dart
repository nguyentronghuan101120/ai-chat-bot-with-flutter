import 'package:ai_chat_bot/constants/hive_type_definition.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'enum.g.dart';

@HiveType(typeId: HiveTypeDefinition.chatRole)
enum ChatRole {
  @HiveField(0)
  @JsonValue('user')
  user,

  @HiveField(1)
  @JsonValue('assistant')
  assistant,

  @HiveField(2)
  file,
}

enum FileType {
  @JsonValue('pdf')
  pdf,
  @JsonValue('docx')
  docx,
}
