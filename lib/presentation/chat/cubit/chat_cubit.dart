import 'package:ai_chat_bot/constants/set_of_tools.dart';
import 'package:ai_chat_bot/data/models/ui_model/chat_model.dart';
import 'package:ai_chat_bot/domain/chat_repository.dart';
import 'package:ai_chat_bot/domain/image_repository.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._chatRepository,
    this._imageRepository,
  ) : super(ChatInitial());

  final ChatRepository _chatRepository;
  final ImageRepository _imageRepository;

  String _accumulatedToolCallArgs = '';
  bool _processingToolCall = false;
  String _currentToolCallName = '';

  void sendMessage(List<ChatModel> chatHistories) {
    emit(InChattingWithBot(chatHistories));

    // Reset tool call state at the beginning of a new message
    _resetToolCallState();

    _chatRepository
        .sendMessageStream(chatHistories.map((e) => e.message).toList())
        .listen(
      (event) async {
        final latestMessage =
            event.choices.first.delta.content?.first?.text ?? '';

        final toolCalls = event.choices.first.delta.toolCalls;
        if (toolCalls != null && toolCalls.isNotEmpty) {
          final newMessage = await _processToolCall(toolCalls);
          if (newMessage != null) {
            chatHistories.removeLast();
            chatHistories.add(newMessage);
          }
        }

        // If we're not processing a tool call or we received content, handle the message
        if (!_processingToolCall) {
          _updateLastAssistantMessage(
            chatHistories: chatHistories,
            latestMessage: latestMessage,
          );

          emit(BotChatGenerating(List.from(chatHistories)));
        }
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

  Future<ChatModel> _generateImage(String prompt) async {
    final imagePath = await _imageRepository.generateImage(prompt);

    return ChatModel(
      message: OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "Generated image based on prompt: $prompt\n"),
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            imagePath,
          ),
        ],
        role: OpenAIChatMessageRole.assistant,
      ),
      isLoading: false,
    );
  }

  void _updateLastAssistantMessage({
    required List<ChatModel> chatHistories,
    required String latestMessage,
  }) {
    final lastMessageContent =
        chatHistories.last.message.content?.first.text ?? '';
    final imagePath = chatHistories.last.message.content
        ?.where(
            (item) => Uri.tryParse(item.text ?? '')?.hasAbsolutePath ?? false)
        .firstOrNull
        ?.text;

    chatHistories.last = ChatModel(
      message: OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            lastMessageContent + latestMessage,
          ),
          if (imagePath != null)
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              imagePath,
            ),
        ],
        role: OpenAIChatMessageRole.assistant,
      ),
      isLoading: false,
    );
  }

  ChatModel _newAssistantMessage({String? latestMessage, String? imagePath}) {
    final chatModel = ChatModel(
      message: OpenAIChatCompletionChoiceMessageModel(
        content: [
          if (latestMessage != null)
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
                latestMessage),
          if (imagePath != null)
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              imagePath,
            ),
        ],
        role: OpenAIChatMessageRole.assistant,
      ),
      isLoading: false,
    );

    return chatModel;
  }

  Future<ChatModel?> _processToolCall(final toolCalls) async {
    // Check if this is a tool call response
    if (toolCalls != null && toolCalls.isNotEmpty) {
      _processingToolCall = true;
      final call = toolCalls.first;
      if (call.function.name != null) {
        _currentToolCallName = call.function.name ?? '';
      }
      // Accumulate the arguments
      if (call.function.arguments != null) {
        _accumulatedToolCallArgs += call.function.arguments;
      }
    }

    // Try to parse the JSON - if it's valid, we can process the tool call
    if (_accumulatedToolCallArgs.trim().endsWith('}')) {
      final decodedArgs = jsonDecode(_accumulatedToolCallArgs);

      if (_currentToolCallName == SetOfTools.generateImage.name) {
        final prompt = decodedArgs["prompt"];
        if (prompt != null) {
          // Call the image generation function
          final imageChatModel = await _generateImage(prompt);

          final newMessage = _newAssistantMessage(
            latestMessage: "Generated image based on prompt: $prompt\n",
            imagePath: imageChatModel.message.content
                ?.where((item) =>
                    Uri.tryParse(item.text ?? '')?.hasAbsolutePath ?? false)
                .first
                .text,
          );

          // Reset tool call state
          _resetToolCallState();
          return newMessage;
        }
      }
    }
    return null;
  }

  void _resetToolCallState() {
    _accumulatedToolCallArgs = '';
    _processingToolCall = false;
    _currentToolCallName = '';
  }
}
