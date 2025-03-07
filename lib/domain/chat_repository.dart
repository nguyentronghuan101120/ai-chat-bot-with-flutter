import 'dart:async';

import 'package:dart_openai/dart_openai.dart';

abstract class ChatRepository {
  Stream<OpenAIStreamChatCompletionModel> sendMessageStream(
      List<OpenAIChatCompletionChoiceMessageModel> messages);
}
