import 'package:file_picker/file_picker.dart';

abstract class FileRepository {
  Future<String> uploadAndProcessFile({
    required PlatformFile file,
    String? sessionChatId,
  });
}
