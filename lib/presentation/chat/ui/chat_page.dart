import 'package:ai_chat_bot/domain/repositories/chat_repository.dart';
import 'package:ai_chat_bot/domain/repositories/file_repository.dart';
import 'package:ai_chat_bot/presentation/chat/ui/widgets/chatting_with_bot_widget.dart';
import 'package:ai_chat_bot/presentation/chat/ui/widgets/initial_chat_widget.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_cubit.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_state.dart';
import 'package:ai_chat_bot/presentation/common/error_widget.dart';
import 'package:ai_chat_bot/utils/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(
        getIt<ChatRepository>(),
        getIt<FileRepository>(),
      ),
      child: BlocBuilder<ChatCubit, ChatState>(
        buildWhen: (previous, current) =>
            current is InChattingWithBot || current is ChatError,
        builder: (context, state) {
          if (state is InChattingWithBot) {
            return ChattingWithBotWidget();
          } else if (state is ChatError) {
            return BaseErrorWidget(message: state.message);
          }

          return InitialChatWidget();
        },
      ),
    );
  }
}
