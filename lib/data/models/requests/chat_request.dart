import 'package:ai_chat_bot/data/models/requests/chat_message.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_request.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatRequest {
  const ChatRequest({
    required this.prompt,
    this.hasFile = false,
    this.chatSessionId,
  });

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);

  final List<ChatMessage> prompt;
  @JsonKey(name: 'has_file')
  final bool hasFile;
  @JsonKey(name: 'chat_session_id')
  final String? chatSessionId;

  Map<String, dynamic> toJson() => _$ChatRequestToJson(this);
}
