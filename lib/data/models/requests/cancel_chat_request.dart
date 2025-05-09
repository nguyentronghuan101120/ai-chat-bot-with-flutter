import 'package:json_annotation/json_annotation.dart';
part 'cancel_chat_request.g.dart';

@JsonSerializable()
class CancelChatRequest {
  @JsonKey(name: 'chat_session_id')
  final String chatSessionId;

  const CancelChatRequest({required this.chatSessionId});

  factory CancelChatRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CancelChatRequestToJson(this);
}
