import 'package:ai_chat_bot/data/models/ui_model/chat_model.dart';
import 'package:ai_chat_bot/domain/chat_repository.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._chatRepository) : super(ChatInitial());

  final ChatRepository _chatRepository;

  void sendMessage(List<ChatModel> chatHistories) {
    emit(InChattingWithBot(chatHistories));

    _chatRepository
        .sendMessageStream(chatHistories.map((e) => e.message).toList())
        .listen((event) {
      final latestMessage =
          event.choices.first.delta.content?.first?.text ?? '';

      if (_isLastMessageFromAssistant(chatHistories)) {
        _updateLastAssistantMessage(chatHistories, latestMessage);
      } else {
        _addNewAssistantMessage(chatHistories, latestMessage);
      }

      emit(BotChatGenerating(List.from(chatHistories)));
    }, onError: (error) {
      emit(ChatError(error.toString()));
    }, onDone: () {
      emit(BotChatGenerateStopped());
    });
  }

  bool _isLastMessageFromAssistant(List<ChatModel> chatHistories) {
    return chatHistories.isNotEmpty &&
        chatHistories.last.message.role == OpenAIChatMessageRole.assistant;
  }

  void _updateLastAssistantMessage(
      List<ChatModel> chatHistories, String latestMessage) {
    final lastMessageContent =
        chatHistories.last.message.content?.first.text ?? '';
    chatHistories.last = ChatModel(
      message: OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            lastMessageContent + latestMessage,
          ),
        ],
        role: OpenAIChatMessageRole.assistant,
      ),
      isLoading: false,
    );
  }

  void _addNewAssistantMessage(
      List<ChatModel> chatHistories, String latestMessage) {
    chatHistories.add(ChatModel(
      message: OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(latestMessage),
        ],
        role: OpenAIChatMessageRole.assistant,
      ),
      isLoading: false,
    ));
  }
}
