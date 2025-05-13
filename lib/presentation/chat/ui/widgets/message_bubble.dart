import 'dart:io';

import 'package:ai_chat_bot/constants/enum.dart';
import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:ai_chat_bot/gen/locale_keys.g.dart';
import 'package:ai_chat_bot/presentation/common/files_list_widget.dart';
import 'package:ai_chat_bot/presentation/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that displays a single message in a chat interface.
class MessageBubble extends StatefulWidget {
  final ChatEntity content;
  final Function(String) onEdit;
  final VoidCallback onResend;

  const MessageBubble({
    super.key,
    required this.content,
    required this.onEdit,
    required this.onResend,
  });

  @override
  MessageBubbleState createState() => MessageBubbleState();
}

class MessageBubbleState extends State<MessageBubble> {
  final TextEditingController _editController = TextEditingController();
  bool _isHovered = false;
  bool _isEditing = false;

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

  @override
  Widget build(BuildContext context) {
    final isUser = widget.content.role == ChatRole.user;
    final isFile = widget.content.role == ChatRole.file;
    final textColor = isUser ? Colors.white : Colors.black;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 768,
          child: Column(
            crossAxisAlignment: isUser || isFile
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              _MessageContent(
                content: widget.content,
                isUser: isUser,
                textColor: textColor,
                isEditing: _isEditing,
                editController: _editController,
                onEdit: (text) {
                  setState(() => _isEditing = false);
                  widget.onEdit(text);
                },
                onCancelEdit: () {
                  setState(() {
                    _isEditing = false;
                    _editController.text = widget.content.message;
                  });
                },
              ),
              if (widget.content.role != ChatRole.file &&
                  widget.content.message.isNotEmpty)
                _MessageActions(
                  isHovered: _isHovered,
                  isEditing: _isEditing,
                  isUser: isUser,
                  onEdit: () => setState(() => _isEditing = true),
                  onResend: widget.onResend,
                  onCopy: () => _copyToClipboard(widget.content.message),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
    );
  }
}

/// Widget that displays the main content of the message.
class _MessageContent extends StatelessWidget {
  final ChatEntity content;
  final bool isUser;
  final Color textColor;
  final bool isEditing;
  final TextEditingController editController;
  final Function(String) onEdit;
  final VoidCallback onCancelEdit;

  const _MessageContent({
    required this.content,
    required this.isUser,
    required this.textColor,
    required this.isEditing,
    required this.editController,
    required this.onEdit,
    required this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    return content.role == ChatRole.file
        ? FilesListWidget(
            selectedFiles: content.files!,
            onRemove: (file) {},
          )
        : content.message.isEmpty && content.role == ChatRole.user
            ? const SizedBox.shrink()
            : Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.black54 : null,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isUser ? const Radius.circular(2) : null,
                      bottomLeft: !isUser ? const Radius.circular(2) : null,
                    ),
                    boxShadow: isUser
                        ? [
                            BoxShadow(
                              color: Colors.black.withAlpha(100),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: content.isLoading && !isUser
                      ? const LoadingWidget()
                      : Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (isEditing && isUser)
                              _EditMessageForm(
                                controller: editController,
                                textColor: textColor,
                                onSave: onEdit,
                                onCancel: onCancelEdit,
                              )
                            else ...[
                              _MessageText(
                                message: content.message,
                                isUser: isUser,
                                textColor: textColor,
                              ),
                              if (content.role == ChatRole.assistant &&
                                  content.hasCanceled)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.remove_circle_outline,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      'User canceled',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    )
                                  ],
                                ),
                            ],
                          ],
                        ),
                ),
              );
  }
}

/// Widget for editing a message.
class _EditMessageForm extends StatelessWidget {
  final TextEditingController controller;
  final Color textColor;
  final Function(String) onSave;
  final VoidCallback onCancel;

  const _EditMessageForm({
    required this.controller,
    required this.textColor,
    required this.onSave,
    required this.onCancel,
  });

  Future<void> _showDiscardDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.discardChanges.tr()),
        content: Text(LocaleKeys.areYouSureYouWantToDiscardYourChanges.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(LocaleKeys.discard.tr()),
          ),
        ],
      ),
    );

    if (result == true) {
      onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          maxLines: null,
          style: TextStyle(color: textColor, fontSize: 16),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          autofocus: true,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: textColor),
              onPressed: () => onSave(controller.text),
            ),
            IconButton(
              icon: Icon(Icons.close, color: textColor),
              onPressed: () => _showDiscardDialog(context),
            ),
          ],
        )
      ],
    );
  }
}

/// Widget that displays the message text with markdown support and image handling.
class _MessageText extends StatelessWidget {
  final String message;
  final bool isUser;
  final Color textColor;

  const _MessageText({
    required this.message,
    required this.isUser,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final (beforeImage, imageUrl, afterImage) =
        _splitMessageAroundImage(message);

    List<Widget> children = [];

    if (beforeImage.isNotEmpty) {
      children.add(_MarkdownText(
        text: beforeImage,
        isUser: isUser,
        textColor: textColor,
      ));
    }

    if (imageUrl != null && Uri.tryParse(imageUrl)?.hasAbsolutePath == true) {
      children.add(_MessageImage(imageUrl: imageUrl));
    }

    if (afterImage.isNotEmpty) {
      children.add(_MarkdownText(
        text: afterImage,
        isUser: isUser,
        textColor: textColor,
      ));
    }

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: children,
    );
  }

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
}

/// Widget that displays markdown text with proper styling.
class _MarkdownText extends StatelessWidget {
  final String text;
  final bool isUser;
  final Color textColor;

  const _MarkdownText({
    required this.text,
    required this.isUser,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: textColor, fontSize: 16, height: 1.5),
        strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        listBullet: TextStyle(color: textColor, fontSize: 16),
        a: TextStyle(
          color: isUser ? Colors.lightBlue[200] : Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          _launchUrl(href);
        }
      },
    );
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
}

/// Widget that displays an image in the message.
class _MessageImage extends StatelessWidget {
  final String imageUrl;

  const _MessageImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 512.w,
        maxHeight: 512.h,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Platform.isMacOS
          ? Image.network(
              imageUrl,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const LoadingWidget();
              },
            )
          : CachedNetworkImage(
              imageUrl: imageUrl,
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.contain,
            ),
    );
  }
}

/// Widget that displays action buttons for the message.
class _MessageActions extends StatelessWidget {
  final bool isHovered;
  final bool isEditing;
  final bool isUser;
  final VoidCallback onEdit;
  final VoidCallback onResend;
  final VoidCallback onCopy;

  const _MessageActions({
    required this.isHovered,
    required this.isEditing,
    required this.isUser,
    required this.onEdit,
    required this.onResend,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isHovered && !isEditing ? 1.0 : 0.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUser) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.refresh_outlined, size: 20),
              onPressed: onResend,
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 20),
              onPressed: onCopy,
            ),
          ],
          if (!isUser)
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 20),
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }
}
