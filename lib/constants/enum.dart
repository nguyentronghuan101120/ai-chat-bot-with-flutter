import 'package:json_annotation/json_annotation.dart';

enum ChatRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('tool')
  tool,
  @JsonValue('system')
  system,
}
