import 'package:ai_chat_bot/data/models/ui_model/chat_model.dart';
import 'package:equatable/equatable.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

final class InChattingWithBot extends ChatState {
  final List<ChatModel> messages;

  const InChattingWithBot(this.messages);

  @override
  List<Object> get props => [messages];
}

final class BotChatGenerating extends ChatState {
  final List<ChatModel> messages;

  const BotChatGenerating(this.messages);

  @override
  List<Object> get props => [messages];
}

final class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
