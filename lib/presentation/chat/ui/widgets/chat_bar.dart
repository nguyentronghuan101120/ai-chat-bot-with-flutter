import 'package:flutter/material.dart';

class ChatBarWidget extends StatefulWidget {
  const ChatBarWidget({super.key, required this.onSubmit});
  final Function(String) onSubmit;

  @override
  State<ChatBarWidget> createState() => _ChatBarWidgetState();
}

class _ChatBarWidgetState extends State<ChatBarWidget> {
  final TextEditingController _messageController = TextEditingController();

  bool _isSending = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.psychology), // Reason icon
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb), // Deep Think icon
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.onSubmit(value);
                  _messageController.clear();
                  _focusNode.requestFocus();
                }
              },
              focusNode: _focusNode,
            ),
          ),
          _isSending
              ? IconButton(
                  icon: const Icon(Icons.stop_circle, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _isSending = false;
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      widget.onSubmit(_messageController.text);
                      _messageController.clear();
                      _focusNode.requestFocus();
                    }
                  },
                ),
        ],
      ),
    );
  }
}
