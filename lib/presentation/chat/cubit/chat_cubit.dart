import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:ai_chat_bot/domain/repositories/chat_repository.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._chatRepository,
  ) : super(ChatInitial());

  final ChatRepository _chatRepository;

  void sendMessage(List<ChatEntity> chatHistories) {
    emit(InChattingWithBot(chatHistories));

    _chatRepository.streamChat(chatHistories).listen(
      (event) async {
        final latestMessage = event.message;

        chatHistories.last = chatHistories.last.copyWith(
          message: latestMessage,
          isLoading: event.isLoading,
        );

        emit(BotChatGenerating(List.from(chatHistories)));
      },
      onError: (error) {
        emit(ChatError(error.toString()));

        throw Exception(error);
      },
      onDone: () {
        emit(BotChatGenerateStopped(chatHistories));
      },
      cancelOnError: true,
    );
  }
}
