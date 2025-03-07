import 'dart:async';
import 'package:ai_chat_bot/domain/chat_repository.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._chatRepository) : super(ChatInitial());

  final ChatRepository _chatRepository;
  final List<OpenAIChatCompletionChoiceMessageModel> _messages = [];
  StreamSubscription<OpenAIStreamChatCompletionModel>? _subscription;

  void sendMessage(List<OpenAIChatCompletionChoiceMessageModel> history) {
    emit(ChatLoading());

    // Sao chép lịch sử chat vào danh sách
    _messages.clear();
    _messages.addAll(history);

    // Bắt đầu lắng nghe stream dữ liệu từ OpenAI
    _subscription?.cancel();
    _subscription = _chatRepository.sendMessageStream(_messages).listen(
      (event) {
        final content = event.choices.first.delta.content;
        final latestMessage = content?.first?.text ?? '';

        if (_messages.isNotEmpty &&
            _messages.last.role == OpenAIChatMessageRole.assistant) {
          // Cập nhật tin nhắn của bot
          _messages.last = OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                (_messages.last.content?.first.text ?? '') + latestMessage,
              ),
            ],
            role: OpenAIChatMessageRole.assistant,
          );
        } else {
          // Thêm tin nhắn mới từ bot
          _messages.add(OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  latestMessage)
            ],
            role: OpenAIChatMessageRole.assistant,
          ));
        }

        // Emit để cập nhật UI
        emit(ChatLoaded(List.from(_messages)));
      },
      onError: (error) {
        emit(ChatError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
