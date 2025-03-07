import 'package:ai_chat_bot/presentation/chat/ui/widgets/chat_bar.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

class ChatLoadedWidget extends StatelessWidget {
  const ChatLoadedWidget({
    super.key,
    required this.onSubmit,
    required this.messages,
  });

  final Function(String) onSubmit;
  final List<OpenAIChatCompletionChoiceMessageModel> messages;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isUserMessage = message.role == OpenAIChatMessageRole.user;

              return Align(
                alignment: isUserMessage
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUserMessage ? Colors.black54 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight:
                          isUserMessage ? const Radius.circular(2) : null,
                    ),
                  ),
                  child: Text(
                    message.content?.first.text ?? '',
                    style: TextStyle(
                      color: isUserMessage ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ChatBarWidget(onSubmit: onSubmit),
      ],
    );
  }
}
