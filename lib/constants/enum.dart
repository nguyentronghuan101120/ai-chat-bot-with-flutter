import 'package:json_annotation/json_annotation.dart';

enum ChatRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
}

enum FileType {
  @JsonValue('pdf')
  pdf,
  @JsonValue('docx')
  docx,
}
