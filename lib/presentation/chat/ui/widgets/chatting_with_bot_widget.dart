import 'package:ai_chat_bot/data/models/ui_model/chat_model.dart';
import 'package:ai_chat_bot/presentation/base/ui/base_page.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_cubit.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:ai_chat_bot/presentation/chat/ui/widgets/chat_bar.dart';
import 'package:ai_chat_bot/presentation/common/loading_widget.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChattingWithBotWidget extends StatelessWidget {
  ChattingWithBotWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Chat',
      bodyForMobile: _buildBody(context),
      bodyForDesktop: _buildBody(context),
    );
  }

  final ScrollController _scrollController = ScrollController();

  final List<ChatModel> _chatHistories = [];

  void _handleMessageSubmit(BuildContext context, String message) async {
    _chatHistories.addAll([
      ChatModel(
        isLoading: false,
        message: OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
          ],
          role: OpenAIChatMessageRole.user,
        ),
      ),
      ChatModel(
        isLoading: true,
        message: OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(''),
          ],
          role: OpenAIChatMessageRole.assistant,
        ),
      ),
    ]);
    context.read<ChatCubit>().sendMessage(_chatHistories);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              List<ChatModel> chatHistories = [];
              if (state is InChattingWithBot || state is BotChatGenerating) {
                chatHistories = (state as dynamic).messages;
                chatHistories = chatHistories
                    .where(
                        (m) => m.message.role != OpenAIChatMessageRole.system)
                    .toList();
                _chatHistories.clear();
                _chatHistories.addAll(chatHistories);
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                itemCount: _chatHistories.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (index == _chatHistories.length - 1) {
                    _scrollToBottom();
                  }
                  return _MessageBubble(
                    message: _chatHistories[index].message,
                    isUserMessage: _chatHistories[index].message.role ==
                        OpenAIChatMessageRole.user,
                    isLoading: _chatHistories[index].isLoading,
                  );
                },
              );
            },
          ),
        ),
        ChatBarWidget(onSubmit: (msg) async {
          _scrollToBottom();
          _handleMessageSubmit(context, msg);
        }),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final OpenAIChatCompletionChoiceMessageModel message;
  final bool isUserMessage;
  final bool isLoading;

  const _MessageBubble({
    required this.message,
    required this.isUserMessage,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 768,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUserMessage ? Colors.black54 : Colors.grey[200],
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isUserMessage ? Radius.circular(2) : null,
            ),
          ),
          child: isLoading && !isUserMessage
              ? const LoadingWidget()
              : Text(
                  message.content?.first.text ?? '',
                  style: TextStyle(
                    color: isUserMessage ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
