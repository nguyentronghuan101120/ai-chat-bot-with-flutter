import 'package:ai_chat_bot/constants/enum.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

class ChatEntity extends Equatable {
  final String message;
  final ChatRole role;
  final bool isLoading;
  final List<PlatformFile>? files;

  const ChatEntity({
    required this.message,
    required this.role,
    required this.isLoading,
    this.files,
  });

  ChatEntity copyWith({
    String? message,
    ChatRole? role,
    bool? isLoading,
    List<PlatformFile>? files,
  }) {
    return ChatEntity(
        message: message ?? this.message,
        role: role ?? this.role,
        isLoading: isLoading ?? this.isLoading,
        files: files ?? this.files);
  }

  @override
  List<Object?> get props => [message, role, isLoading, files];
}
