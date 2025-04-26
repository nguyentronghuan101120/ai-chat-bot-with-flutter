import 'package:ai_chat_bot/data/models/requests/chat_message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_request.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatRequest {
  const ChatRequest({required this.prompt});

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);

  final List<ChatMessage> prompt;

  Map<String, dynamic> toJson() => _$ChatRequestToJson(this);
}
