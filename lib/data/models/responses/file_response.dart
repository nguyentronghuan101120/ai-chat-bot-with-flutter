import 'package:ai_chat_bot/constants/enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'file_response.g.dart';

@JsonSerializable(explicitToJson: true)
class FileResponse {
  final String? id;
  final FileType? type;

  FileResponse({
    this.id,
    this.type,
  });

  factory FileResponse.fromJson(Map<String, dynamic> json) =>
      _$FileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FileResponseToJson(this);
}
