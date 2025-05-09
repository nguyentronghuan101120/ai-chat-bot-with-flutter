import 'package:ai_chat_bot/constants/enum.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

class ChatEntity extends Equatable {
  final String message;
  final ChatRole role;
  final bool isLoading;
  final List<PlatformFile>? files;
  final String? chatSessionId;
  final bool hasCanceled;

  const ChatEntity({
    required this.message,
    required this.role,
    required this.isLoading,
    this.files,
    this.chatSessionId,
    this.hasCanceled = false,
  });

  ChatEntity copyWith({
    String? message,
    ChatRole? role,
    bool? isLoading,
    List<PlatformFile>? files,
    String? chatSessionId,
    bool? hasCanceled,
  }) {
    return ChatEntity(
      message: message ?? this.message,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      files: files ?? this.files,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      hasCanceled: hasCanceled ?? this.hasCanceled,
    );
  }

  @override
  List<Object?> get props => [message, role, isLoading, files];
}
