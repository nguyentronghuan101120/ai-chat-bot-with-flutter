import 'dart:io';

import 'package:ai_chat_bot/constants/enum.dart';
import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:ai_chat_bot/gen/locale_keys.g.dart';
import 'package:ai_chat_bot/presentation/base/ui/base_page.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_cubit.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:ai_chat_bot/presentation/chat/ui/widgets/chat_bar.dart';
import 'package:ai_chat_bot/presentation/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // Added for clipboard functionality

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
                  return _MessageBubble(
                    content: _chatHistories[index],
                    onEdit: (message) {
                      // Handle edit: for simplicity, resend the edited message
                      _handleMessageSubmit(context, message);
                    },
                    onResend: () {
                      // Resend the original message
                      _handleMessageSubmit(
                          context, _chatHistories[index].message);
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

class _MessageBubble extends StatefulWidget {
  final ChatEntity content;
  final Function(String) onEdit;
  final VoidCallback onResend;

  const _MessageBubble({
    required this.content,
    required this.onEdit,
    required this.onResend,
  });

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _isHovered = false;
  bool _isClicked = false;
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editController.text = widget.content.message;
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  // Function to split message around Markdown image syntax and extract the URL
  (String, String?, String) _splitMessageAroundImage(String message) {
    final regExp = RegExp(r'!\[.*?\]\((.*?)\)');

    final match = regExp.firstMatch(message);

    if (match != null) {
      String? imageUrl = match.group(1);
      int start = match.start;
      int end = match.end;
      String beforeImage = message.substring(0, start).trim();
      String afterImage = message.substring(end).trim();
      return (beforeImage, imageUrl, afterImage);
    }

    return (message, null, '');
  }

  Future<void> _launchUrl(String url) async {
    String urlWithScheme = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      urlWithScheme = 'https://$url';
    }

    final Uri uri = Uri.parse(urlWithScheme);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final isUser = content.role == ChatRole.user;
    final textColor = isUser ? Colors.white : Colors.black;
    final backgroundColor = isUser ? Colors.black54 : Colors.grey[100];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 768,
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _isClicked = !_isClicked);
                },
                child: Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(2) : null,
                        bottomLeft: !isUser ? const Radius.circular(2) : null,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(100),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: content.isLoading && !isUser
                        ? const LoadingWidget()
                        : Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Builder(
                                builder: (context) {
                                  final (beforeImage, imageUrl, afterImage) =
                                      _splitMessageAroundImage(content.message);

                                  List<Widget> children = [];

                                  if (beforeImage.isNotEmpty) {
                                    children.add(
                                      MarkdownBody(
                                        data: beforeImage,
                                        selectable: true,
                                        onSelectionChanged:
                                            (text, selection, cause) {},
                                        styleSheet: MarkdownStyleSheet(
                                          p: TextStyle(
                                            color: textColor,
                                            fontSize: 16,
                                            height: 1.5,
                                          ),
                                          strong: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          listBullet: TextStyle(
                                            color: textColor,
                                            fontSize: 16,
                                          ),
                                          a: TextStyle(
                                            color: isUser
                                                ? Colors.lightBlue[200]
                                                : Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        onTapLink: (text, href, title) {
                                          if (href != null) {
                                            _launchUrl(href);
                                          }
                                        },
                                      ),
                                    );
                                  }

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
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Platform.isMacOS
                                            ? Image.network(
                                                imageUrl,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(
                                                      Icons.error);
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

                                  if (afterImage.isNotEmpty) {
                                    children.add(
                                      MarkdownBody(
                                        data: afterImage,
                                        selectable: true,
                                        styleSheet: MarkdownStyleSheet(
                                          p: TextStyle(
                                            color: textColor,
                                            fontSize: 16,
                                            height: 1.5,
                                          ),
                                          strong: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          listBullet: TextStyle(
                                            color: textColor,
                                            fontSize: 16,
                                          ),
                                          a: TextStyle(
                                            color: isUser
                                                ? Colors.lightBlue[200]
                                                : Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        onTapLink: (text, href, title) {
                                          if (href != null) {
                                            _launchUrl(href);
                                          }
                                        },
                                      ),
                                    );
                                  }

                                  return Column(
                                    crossAxisAlignment: isUser
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
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUser) ...[
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(LocaleKeys.edit.tr()),
                            content: TextField(
                              controller: _editController,
                              maxLines: 5,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(LocaleKeys.cancel.tr()),
                              ),
                              TextButton(
                                onPressed: () {
                                  widget.onEdit(_editController.text);
                                  Navigator.pop(context);
                                },
                                child: Text(LocaleKeys.save.tr()),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh_outlined, size: 20),
                      onPressed: widget.onResend,
                    ),
                  ],
                  if (!isUser)
                    IconButton(
                      icon: Icon(Icons.copy_outlined, size: 20),
                      onPressed: () => _copyToClipboard(content.message),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
