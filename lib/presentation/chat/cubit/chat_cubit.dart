import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:ai_chat_bot/domain/repositories/chat_repository.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._chatRepository,
  ) : super(ChatInitial());

  final ChatRepository _chatRepository;

  bool _processingToolCall = false;

  void sendMessage(List<ChatEntity> chatHistories) {
    emit(InChattingWithBot(chatHistories));

    // Reset tool call state at the beginning of a new message
    _resetToolCallState();

    _chatRepository.streamChat(chatHistories).listen(
      (event) async {
        final latestMessage = event.message;

        // final toolCalls = event.choices.first.delta.toolCalls;
        // if (toolCalls != null && toolCalls.isNotEmpty) {
        //   final newMessage = await _processToolCall(toolCalls);
        //   if (newMessage != null) {
        //     chatHistories.removeLast();
        //     chatHistories.add(newMessage);
        //   }
        // }

        if (!_processingToolCall) {
          chatHistories.last = chatHistories.last.copyWith(
            message: latestMessage,
            isLoading: event.isLoading,
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

  // Future<ChatModel> _generateImage(String prompt) async {
  //   final imagePath = await _imageRepository.generateImage(prompt);

  //   return ChatModel(
  //     message: OpenAIChatCompletionChoiceMessageModel(
  //       content: [
  //         OpenAIChatCompletionChoiceMessageContentItemModel.text(
  //             "Generated image based on prompt: $prompt\n"),
  //         OpenAIChatCompletionChoiceMessageContentItemModel.text(
  //           imagePath,
  //         ),
  //       ],
  //       role: OpenAIChatMessageRole.assistant,
  //     ),
  //     isLoading: false,
  //   );
  // }

  // ChatEntity _newAssistantMessage({required String latestMessage}) {
  //   final chatModel = ChatEntity(
  //     message: latestMessage,
  //     isLoading: false,
  //     role: ChatRole.assistant,
  //   );

  //   return chatModel;
  // }

  // Future<ChatEntity?> _processToolCall(final toolCalls) async {
  //   // Check if this is a tool call response
  //   if (toolCalls != null && toolCalls.isNotEmpty) {
  //     _processingToolCall = true;
  //     final call = toolCalls.first;
  //     if (call.function.name != null) {
  //       _currentToolCallName = call.function.name ?? '';
  //     }
  //     // Accumulate the arguments
  //     if (call.function.arguments != null) {
  //       _accumulatedToolCallArgs += call.function.arguments;
  //     }
  //   }

  //   // Try to parse the JSON - if it's valid, we can process the tool call
  //   if (_accumulatedToolCallArgs.trim().endsWith('}')) {
  //     final decodedArgs = jsonDecode(_accumulatedToolCallArgs);

  //     if (_currentToolCallName == SetOfTools.generateImage.name) {
  //       final prompt = decodedArgs["prompt"];
  //       if (prompt != null) {
  //         // Call the image generation function
  //         final imageChatModel = await _generateImage(prompt);

  //         final newMessage = _newAssistantMessage(
  //           latestMessage: "Generated image based on prompt: $prompt\n",
  //           imagePath: imageChatModel.message.content
  //               ?.where((item) =>
  //                   Uri.tryParse(item.text ?? '')?.hasAbsolutePath ?? false)
  //               .first
  //               .text,
  //         );

  //         // Reset tool call state
  //         _resetToolCallState();
  //         return newMessage;
  //       }
  //     }
  //   }
  //   return null;
  // }

  void _resetToolCallState() {
    _processingToolCall = false;
  }
}
