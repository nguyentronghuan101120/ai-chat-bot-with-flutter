import 'package:dart_openai/dart_openai.dart';

class ChatDataProvider {
  Stream<OpenAIStreamChatCompletionModel> sendMessageStream(List<OpenAIChatCompletionChoiceMessageModel> messages) async* {
    yield* OpenAI.instance.chat.createStream(
      model: "",
      messages: messages,
    );
  }
}
