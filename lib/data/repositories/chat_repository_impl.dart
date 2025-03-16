import 'package:ai_chat_bot/data/data_provider/chat_data_provider.dart';
import 'package:ai_chat_bot/domain/chat_repository.dart';
import 'package:dart_openai/dart_openai.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDataProvider chatDataProvider;

  ChatRepositoryImpl(this.chatDataProvider);

  @override
  Stream<OpenAIStreamChatCompletionModel> sendMessageStream(
      List<OpenAIChatCompletionChoiceMessageModel> messages) async* {
    yield* chatDataProvider.sendMessageStream(messages);
  }
}
