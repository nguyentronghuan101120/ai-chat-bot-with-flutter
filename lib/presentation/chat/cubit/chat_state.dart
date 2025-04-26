import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:equatable/equatable.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

final class InChattingWithBot extends ChatState {
  final List<ChatEntity> messages;

  const InChattingWithBot(this.messages);

  @override
  List<Object> get props => [messages];
}

final class BotChatGenerating extends ChatState {
  final List<ChatEntity> messages;

  const BotChatGenerating(this.messages);

  @override
  List<Object> get props => [messages];
}

final class BotChatGenerateStopped extends ChatState {
  final List<ChatEntity> messages;

  const BotChatGenerateStopped(this.messages);

  @override
  List<Object> get props => [messages];
}

final class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
