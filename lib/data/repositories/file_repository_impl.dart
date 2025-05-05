import 'dart:io';

import 'package:ai_chat_bot/data/data_sources/file_process_sources.dart';
import 'package:ai_chat_bot/data/models/requests/process_file_request.dart';
import 'package:ai_chat_bot/data/models/responses/file_response.dart';
import 'package:ai_chat_bot/domain/repositories/file_repository.dart';
import 'package:file_picker/file_picker.dart';

class FileRepositoryImpl implements FileRepository {
  final FileProcessSources _sources;

  FileRepositoryImpl(this._sources);

  @override
  Future<FileResponse> uploadFile(PlatformFile file) async {
    final fileData = File(file.path!);

    final response = await _sources.uploadFile(fileData);

    return response.data;
  }

  @override
  Future<String> processFile(ProcessFileRequest request) async {
    final response = await _sources.processFile(request);

    return response.data;
  }
}
