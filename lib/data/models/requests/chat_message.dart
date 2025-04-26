import 'package:ai_chat_bot/constants/enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatMessage {
  const ChatMessage({
    required this.content,
    required this.role,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  final String content;
  final ChatRole role;

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}
