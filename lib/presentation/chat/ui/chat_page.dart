import 'package:ai_chat_bot/constants/system_prompt.dart';
import 'package:ai_chat_bot/domain/chat_repository.dart';
import 'package:ai_chat_bot/presentation/chat/ui/widgets/chat_loaded_widget.dart';
import 'package:ai_chat_bot/presentation/chat/ui/widgets/initial_chat_widget.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_cubit.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:ai_chat_bot/utils/service_locator.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<OpenAIChatCompletionChoiceMessageModel> _chatHistory = [
    SystemPrompt().systemPrompt,
  ];

  void _handleMessageSubmit(BuildContext context, String message) {
    _chatHistory.add(
      OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
        ],
        role: OpenAIChatMessageRole.user,
      ),
    );
    context.read<ChatCubit>().sendMessage(_chatHistory);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(getIt<ChatRepository>()),
      child: Scaffold(
        body: BlocConsumer<ChatCubit, ChatState>(
          listener: (context, state) {
            if (state is ChatLoaded && state.messages.isNotEmpty) {
              final lastMessage = state.messages.last;
              if (_chatHistory.isNotEmpty &&
                  _chatHistory.last.role == OpenAIChatMessageRole.assistant) {
                _chatHistory.last = lastMessage; // Cập nhật tin nhắn AI cuối
              } else {
                _chatHistory.add(lastMessage); // Thêm tin nhắn mới
              }
            }
          },
          builder: (context, state) {
            final messages = _chatHistory
                .where((m) => m.role != OpenAIChatMessageRole.system)
                .toList();

            return (state is ChatLoaded || state is ChatLoading)
                ? ChatLoadedWidget(
                    messages: messages,
                    onSubmit: (msg) => _handleMessageSubmit(context, msg))
                : InitialChatWidget(
                    onSubmit: (msg) => _handleMessageSubmit(context, msg));
          },
        ),
      ),
    );
  }
}
