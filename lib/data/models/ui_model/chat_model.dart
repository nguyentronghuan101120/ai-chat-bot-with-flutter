import 'package:dart_openai/dart_openai.dart';

class ChatModel {
  final OpenAIChatCompletionChoiceMessageModel message;
  final bool isLoading;

  ChatModel({required this.message, required this.isLoading});

  ChatModel copyWith({
    OpenAIChatCompletionChoiceMessageModel? message,
    bool? isLoading,
  }) {
    return ChatModel(
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
