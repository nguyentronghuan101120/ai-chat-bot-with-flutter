import 'package:ai_chat_bot/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 768),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
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
          Row(
            children: [
              _buildFuntionButton(),
              Spacer(),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (messageController.text.isNotEmpty) {
                    widget.onSubmit(messageController.text);
                    messageController.clear();
                    focusNode.requestFocus();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFuntionButton() {
    return Row(
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
      ],
    );
  }
}
