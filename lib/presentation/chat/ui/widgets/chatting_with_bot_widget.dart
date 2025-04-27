import 'dart:io';

import 'package:ai_chat_bot/constants/enum.dart';
import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:ai_chat_bot/presentation/base/ui/base_page.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_cubit.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:ai_chat_bot/presentation/chat/ui/widgets/chat_bar.dart';
import 'package:ai_chat_bot/presentation/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  void _handleMessageSubmit(BuildContext context, String message) async {
    _chatHistories.addAll([
      ChatEntity(
        isLoading: false,
        message: message,
        role: ChatRole.user,
      ),
      ChatEntity(
        isLoading: true,
        message: '',
        role: ChatRole.assistant,
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
    _isAtBottom = (maxScroll - currentScroll).abs() < 50.h; // 10px tolerance
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
                  return _MessageBubble(
                    content: _chatHistories[index],
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
                if (state is! InChattingWithBot) {
                  _scrollToBottom();
                  _handleMessageSubmit(context, msg);
                }
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
  final ChatEntity content;

  const _MessageBubble({
    required this.content,
  });

  // Function to split message around Markdown image syntax and extract the URL
  (String, String?, String) _splitMessageAroundImage(String message) {
    // Regular expression to match Markdown image syntax: ![alt text](url)
    final regExp = RegExp(r'!\[.*?\]\((.*?)\)');

    // Find the first match
    final match = regExp.firstMatch(message);

    if (match != null) {
      // Extract the URL (group 1)
      String? imageUrl = match.group(1);
      // Get the start and end indices of the Markdown syntax
      int start = match.start;
      int end = match.end;
      // Split the message into before and after the Markdown syntax
      String beforeImage = message.substring(0, start).trim();
      String afterImage = message.substring(end).trim();
      return (beforeImage, imageUrl, afterImage);
    }

    // If no image URL is found, return the original message with null URL
    return (message, null, '');
  }

  @override
  Widget build(BuildContext context) {
    final content = this.content;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 768,
          child: Stack(
            children: [
              Align(
                alignment: content.role == ChatRole.user
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        content.role == ChatRole.user ? Colors.black54 : null,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: content.role == ChatRole.user
                          ? const Radius.circular(2)
                          : null,
                    ),
                  ),
                  child: content.isLoading && content.role != ChatRole.user
                      ? const LoadingWidget()
                      : Column(
                          crossAxisAlignment: content.role == ChatRole.user
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (context) {
                                // Split the message around the image Markdown
                                final (beforeImage, imageUrl, afterImage) =
                                    _splitMessageAroundImage(content.message);

                                // List of widgets to display
                                List<Widget> children = [];

                                // Add the text before the image if it's not empty
                                if (beforeImage.isNotEmpty) {
                                  children.add(
                                    SelectableText(
                                      beforeImage,
                                      style: TextStyle(
                                        color: content.role == ChatRole.user
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }

                                // Add the image if a valid URL is found
                                if (imageUrl != null &&
                                    Uri.tryParse(imageUrl)?.hasAbsolutePath ==
                                        true) {
                                  children.add(
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: 512.w,
                                        maxHeight: 512.h,
                                      ),
                                      margin: EdgeInsets.only(
                                        top: beforeImage.isNotEmpty ? 8 : 0,
                                        bottom: afterImage.isNotEmpty ? 8 : 0,
                                      ),
                                      child: Platform.isMacOS
                                          ? Image.network(
                                              imageUrl,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(Icons.error);
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const LoadingWidget();
                                              },
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                              fit: BoxFit.contain,
                                            ),
                                    ),
                                  );
                                }

                                // Add the text after the image if it's not empty
                                if (afterImage.isNotEmpty) {
                                  children.add(
                                    SelectableText(
                                      afterImage,
                                      style: TextStyle(
                                        color: content.role == ChatRole.user
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  crossAxisAlignment:
                                      content.role == ChatRole.user
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: children,
                                );
                              },
                            ),
                          ],
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
