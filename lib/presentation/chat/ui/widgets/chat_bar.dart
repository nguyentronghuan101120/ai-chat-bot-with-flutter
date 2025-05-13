import 'package:ai_chat_bot/gen/locale_keys.g.dart';
import 'package:ai_chat_bot/presentation/common/files_list_widget.dart';
import 'package:ai_chat_bot/utils/show_message.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class ChatBarWidget extends StatefulWidget {
  const ChatBarWidget({
    super.key,
    required this.onSubmit,
    required this.onStop,
    required this.isStreaming,
    this.onFileSelected,
  });
  final Function(String, List<PlatformFile>) onSubmit;
  final VoidCallback onStop;
  final bool isStreaming;
  final Function(List<PlatformFile>)? onFileSelected;
  @override
  ChatBarWidgetState createState() => ChatBarWidgetState();
}

class ChatBarWidgetState extends State<ChatBarWidget> {
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  bool isStreaming = false;
  List<PlatformFile> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    isStreaming = widget.isStreaming;
  }

  @override
  void didUpdateWidget(ChatBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming != oldWidget.isStreaming) {
      setState(() {
        isStreaming = widget.isStreaming;
      });
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        // Insert a new line when Shift + Enter is pressed
        final cursorPosition = messageController.selection.baseOffset;
        final newText = messageController.text
            .replaceRange(cursorPosition, cursorPosition, '\n');

        messageController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: cursorPosition + 1),
        );

        return KeyEventResult.handled;
      } else {
        // Submit message when only Enter is pressed
        widget.onSubmit(
            messageController.text.trim(), List.from(selectedFiles));
        messageController.clear();
        focusNode.requestFocus();
        selectedFiles.clear();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _onKeyEvent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 768),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilesListWidget(
              selectedFiles: selectedFiles,
              onRemove: (file) {
                setState(() {
                  selectedFiles.remove(file);
                });
              },
              isInitialChat: true,
            ),
            TextField(
              controller: messageController,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: LocaleKeys.typeAMessage.tr(),
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.onSubmit(value, List.from(selectedFiles));
                  messageController.clear();
                  focusNode.requestFocus();
                  selectedFiles.clear();
                }
              },
              focusNode: focusNode,
            ),
            const SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(maxWidth: 768),
              child: Row(
                children: [
                  Expanded(child: _buildFunctionButtons()),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: isStreaming
                        ? IconButton(
                            icon: const Icon(Icons.stop, color: Colors.white),
                            onPressed: widget.onStop,
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () {
                              if (messageController.text.isNotEmpty ||
                                  selectedFiles.isNotEmpty) {
                                widget.onSubmit(messageController.text,
                                    List.from(selectedFiles));
                                messageController.clear();
                                selectedFiles.clear();
                                focusNode.requestFocus();
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
                allowMultiple: true,
              );

              if (result != null && result.files.isNotEmpty) {
                // Filter out duplicates
                final newFiles = result.files
                    .where((file) => !selectedFiles
                        .any((f) => f.name == file.name && f.size == file.size))
                    .toList();

                if (selectedFiles.length >= 10 &&
                    (newFiles.isNotEmpty || newFiles.length > 10) &&
                    mounted) {
                  ShowMessage.showError(
                      context, 'You can only add up to 10 files at a time');
                }

                // Calculate how many files can be added
                final availableSlots = 10 - selectedFiles.length;
                if (availableSlots > 0) {
                  final filesToAdd = newFiles.take(availableSlots).toList();
                  if (filesToAdd.isNotEmpty) {
                    setState(() {
                      selectedFiles.addAll(filesToAdd);
                    });
                    widget.onFileSelected?.call(filesToAdd);
                  }
                }
              }
            },
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.psychology), onPressed: () {}),
          IconButton(icon: const Icon(Icons.lightbulb), onPressed: () {}),
        ],
      ),
    );
  }
}
