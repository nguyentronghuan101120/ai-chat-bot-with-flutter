import 'dart:io';

import 'package:ai_chat_bot/data/models/responses/base_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'file_process_sources.g.dart';

@RestApi()
abstract class FileProcessSources {
  factory FileProcessSources(Dio dio, {String? baseUrl}) = _FileProcessSources;

  @POST('/upload-and-process-file')
  Future<BaseResponse<String>> uploadAndProcessFile(
    @Part() File file,
    @Part(name: 'chat_session_id') String? chatSessionId,
  );
}
