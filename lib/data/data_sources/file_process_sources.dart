import 'dart:io';

import 'package:ai_chat_bot/data/models/requests/process_file_request.dart';
import 'package:ai_chat_bot/data/models/responses/base_response.dart';
import 'package:ai_chat_bot/data/models/responses/file_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'file_process_sources.g.dart';

@RestApi()
abstract class FileProcessSources {
  factory FileProcessSources(Dio dio, {String? baseUrl}) = _FileProcessSources;

  @POST('/upload')
  Future<BaseResponse<FileResponse>> uploadFile(@Part() File file);

  @POST('/process-file')
  Future<BaseResponse<String>> processFile(
    @Body() ProcessFileRequest request,
  );
}
