import 'package:ai_chat_bot/constants/enum.dart';
import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:ai_chat_bot/presentation/base/ui/base_page.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_cubit.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:ai_chat_bot/presentation/chat/ui/widgets/chat_bar.dart';
import 'package:ai_chat_bot/presentation/chat/ui/widgets/message_bubble.dart';
import 'package:file_picker/file_picker.dart';
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
  final List<ChatEntity> _chatHistories = [];

  void _handleMessageSubmit(BuildContext context, String message,
      {int? editIndex, List<PlatformFile>? files}) async {
    if (editIndex != null) {
      // Remove all messages after the edited message
      _chatHistories.removeRange(editIndex + 1, _chatHistories.length);
      // Update the edited message
      _chatHistories[editIndex] = ChatEntity(
        isLoading: false,
        message: message,
        role: ChatRole.user,
      );

      _chatHistories.add(
        ChatEntity(
          isLoading: true,
          message: '',
          role: ChatRole.assistant,
        ),
      );
    } else {
      _chatHistories.addAll([
        if (files != null)
          ChatEntity(
            message: '',
            isLoading: false,
            role: ChatRole.file,
            files: files,
          ),
        ChatEntity(
          isLoading: false,
          message: message,
          role: ChatRole.user,
          files: files,
        ),
        ChatEntity(
          isLoading: true,
          message: '',
          role: ChatRole.assistant,
        ),
      ]);
    }
    context.read<ChatCubit>().sendMessage(
          chatHistories: _chatHistories,
          files: files,
        );
  }

  bool _isAtBottom = true;

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    _isAtBottom = (maxScroll - currentScroll).abs() < 50.h;
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
            builder: (context, state) {
              List<ChatEntity> chatHistories = [];
              chatHistories = ((state as dynamic).messages).toList();
              _chatHistories.clear();
              _chatHistories.addAll(chatHistories);

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 12),
                itemCount: _chatHistories.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (index == _chatHistories.length - 1) {
                    _scrollToBottom();
                  }
                  return MessageBubble(
                    content: _chatHistories[index],
                    onEdit: (message) {
                      _handleMessageSubmit(context, message, editIndex: index);
                    },
                    onResend: () {
                      _handleMessageSubmit(
                          context, _chatHistories[index].message,
                          editIndex: index);
                    },
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
              onSubmit: (msg, files) async {
                if (state is! InChattingWithBot) {
                  _scrollToBottom();
                  _handleMessageSubmit(context, msg, files: files);
                }
              },
              onStop: () {
                context.read<ChatCubit>().stopChat();
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
