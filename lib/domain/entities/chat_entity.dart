import 'package:ai_chat_bot/constants/enum.dart';
import 'package:equatable/equatable.dart';
class ChatEntity extends Equatable {
  final String message;
  final ChatRole role;
  final bool isLoading;

  const ChatEntity({
    required this.message,
    required this.role,
    required this.isLoading,
  });

  ChatEntity copyWith({
    String? message,
    ChatRole? role,
    bool? isLoading,
  }) {
    return ChatEntity(
        message: message ?? this.message,
        role: role ?? this.role,
        isLoading: isLoading ?? this.isLoading);
  }

  @override
  List<Object?> get props => [message, role, isLoading];
}
