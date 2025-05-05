import 'package:ai_chat_bot/data/models/requests/process_file_request.dart';
import 'package:ai_chat_bot/data/models/responses/file_response.dart';
import 'package:file_picker/file_picker.dart';

abstract class FileRepository {
  Future<FileResponse> uploadFile(PlatformFile file);
  Future<String> processFile(ProcessFileRequest request);
}
