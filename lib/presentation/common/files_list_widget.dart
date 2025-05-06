import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilesListWidget extends StatelessWidget {
  const FilesListWidget({
    super.key,
    required this.selectedFiles,
    required this.onRemove,
    this.isInitialChat = false,
  });
  final List<PlatformFile> selectedFiles;
  final Function(PlatformFile) onRemove;
  final bool isInitialChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      padding: selectedFiles.isNotEmpty
          ? const EdgeInsets.symmetric(vertical: 8)
          : const EdgeInsets.all(0),
      child: Wrap(
        children: List.generate(
          selectedFiles.length,
          (index) => _buildFile(index),
        ),
      ),
    );
  }

  Widget _buildFile(int index) {
    final file = selectedFiles[index];
    IconData icon;
    if (file.extension == 'pdf') {
      icon = Icons.picture_as_pdf;
    } else if (["jpg", "jpeg", "png", "gif"].contains(file.extension)) {
      icon = Icons.image;
    } else if (["doc", "docx"].contains(file.extension)) {
      icon = Icons.description;
    } else if (["mp3", "wav"].contains(file.extension)) {
      icon = Icons.audiotrack;
    } else {
      icon = Icons.insert_drive_file;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.withAlpha(300)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 22),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80),
              child: Tooltip(
                message: file.name,
                child: Text(
                  file.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(_formatFileSize(file.size),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 4),
            if (isInitialChat)
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  onRemove(file);
                },
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(Icons.close, size: 18, color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }
}
