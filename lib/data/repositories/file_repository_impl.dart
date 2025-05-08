import 'dart:io';

import 'package:ai_chat_bot/data/data_sources/file_process_sources.dart';
import 'package:ai_chat_bot/domain/repositories/file_repository.dart';
import 'package:file_picker/file_picker.dart';

class FileRepositoryImpl implements FileRepository {
  final FileProcessSources _sources;

  FileRepositoryImpl(this._sources);

  @override
  Future<String> uploadAndProcessFile({
    required PlatformFile file,
    String? chatSessionId,
  }) async {
    final fileData = File(file.path!);

    final response = await _sources.uploadAndProcessFile(
      fileData,
      chatSessionId,
    );

    return response.data;
  }
}
