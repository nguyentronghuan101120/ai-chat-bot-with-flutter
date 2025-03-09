import 'package:ai_chat_bot/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatBarWidget extends StatefulWidget {
  const ChatBarWidget({super.key, required this.onSubmit});
  final Function(String) onSubmit;

  @override
  ChatBarWidgetState createState() => ChatBarWidgetState();
}

class ChatBarWidgetState extends State<ChatBarWidget> {
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

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
        widget.onSubmit(messageController.text.trim());
        messageController.clear();
        focusNode.requestFocus();
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
          children: [
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
                  widget.onSubmit(value);
                  messageController.clear();
                  focusNode.requestFocus();
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
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (messageController.text.isNotEmpty) {
                          widget.onSubmit(messageController.text);
                          messageController.clear();
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
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.psychology), onPressed: () {}),
          IconButton(icon: const Icon(Icons.lightbulb), onPressed: () {}),
        ],
      ),
    );
  }
}
