import 'package:ai_chat_bot/data/models/ui_model/chat_model.dart';
import 'package:ai_chat_bot/presentation/base/ui/base_page.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_cubit.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:ai_chat_bot/presentation/chat/ui/widgets/chat_bar.dart';
import 'package:ai_chat_bot/presentation/common/loading_widget.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChattingWithBotWidget extends StatefulWidget {
  const ChattingWithBotWidget({super.key});

  @override
  State<ChattingWithBotWidget> createState() => _ChattingWithBotWidgetState();
}

class _ChattingWithBotWidgetState extends State<ChattingWithBotWidget> {
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

  bool _isAtBottom = true; // Track whether the user is at the bottom

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Check if the user is at the bottom
    _isAtBottom = (maxScroll - currentScroll).abs() < 100.h; // 10px tolerance
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _isAtBottom &&
          _scrollController.position.userScrollDirection ==
              ScrollDirection.idle) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (previous, current) =>
                current is InChattingWithBot || current is BotChatGenerating,
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
                padding: EdgeInsets.symmetric(vertical: 12.h),
                itemCount: _chatHistories.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (index == _chatHistories.length - 1) {
                    _scrollToBottom();
                  }
                  return _MessageBubble(
                    textMessage:
                        _chatHistories[index].message.content?.first.text ?? '',
                    isUserMessage: _chatHistories[index].message.role ==
                        OpenAIChatMessageRole.user,
                    isLoading: _chatHistories[index].isLoading,
                  );
                },
              );
            },
          ),
        ),
        BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (previous, current) =>
              current is InChattingWithBot || current is BotChatGenerateStopped,
          builder: (context, state) {
            return ChatBarWidget(
              onSubmit: (msg) async {
                _scrollToBottom();
                _handleMessageSubmit(context, msg);
              },
              onStop: () {
                // context.read<ChatCubit>().stopChat();
              },
              isStreaming: state is InChattingWithBot,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Chat',
      bodyForMobile: _buildBody(context),
      bodyForDesktop: _buildBody(context),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String textMessage;
  final bool isUserMessage;
  final bool isLoading;

  const _MessageBubble({
    required this.textMessage,
    required this.isUserMessage,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 768,
          child: Stack(
            children: [
              Align(
                alignment: isUserMessage
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUserMessage ? Colors.black54 : null,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight:
                          isUserMessage ? const Radius.circular(2) : null,
                    ),
                  ),
                  child: isLoading && !isUserMessage
                      ? const LoadingWidget()
                      : Text(
                          textMessage,
                          style: TextStyle(
                            color:
                                isUserMessage ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
