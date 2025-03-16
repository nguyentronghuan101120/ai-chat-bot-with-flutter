import 'package:ai_chat_bot/constants/set_of_tools.dart';
import 'package:dart_openai/dart_openai.dart';

class ChatDataProvider {
  Stream<OpenAIStreamChatCompletionModel> sendMessageStream(
      List<OpenAIChatCompletionChoiceMessageModel> messages) async* {
    yield* OpenAI.instance.chat.createStream(
      model: "",
      messages: messages,
      tools: SetOfTools.values.map((e) => e.tool).toList(),
    );
  }
}
