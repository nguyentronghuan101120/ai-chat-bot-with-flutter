import 'package:ai_chat_bot/constants/enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'process_file_request.g.dart';

@JsonSerializable(explicitToJson: true)
class ProcessFileRequest {
  final String? fileId;
  final FileType? type;

  ProcessFileRequest({this.fileId, this.type});

  factory ProcessFileRequest.fromJson(Map<String, dynamic> json) =>
      _$ProcessFileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessFileRequestToJson(this);
}
