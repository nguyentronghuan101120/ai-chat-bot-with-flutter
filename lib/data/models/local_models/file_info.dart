import 'package:ai_chat_bot/constants/hive_type_definition.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';

part 'file_info.g.dart';

@HiveType(typeId: HiveTypeDefinition.fileInfo)
class FileInfo extends HiveObject {
  @HiveField(0)
  final String fileName;
  @HiveField(1)
  final String filePath;
  @HiveField(2)
  final String mimeType;
  @HiveField(3)
  final int fileSize;

  FileInfo({
    required this.fileName,
    required this.filePath,
    required this.mimeType,
    required this.fileSize,
  });

  factory FileInfo.fromPlatformFile(PlatformFile file, String savedPath) {
    return FileInfo(
      fileName: file.name,
      filePath: savedPath,
      mimeType: file.extension ?? 'unknown',
      fileSize: file.size,
    );
  }
}
