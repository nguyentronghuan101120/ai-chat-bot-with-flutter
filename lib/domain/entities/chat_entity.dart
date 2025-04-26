import 'package:ai_chat_bot/constants/enum.dart';

class ChatEntity {
  final String message;
  final ChatRole role;
  final bool isLoading;

  ChatEntity({
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
}
