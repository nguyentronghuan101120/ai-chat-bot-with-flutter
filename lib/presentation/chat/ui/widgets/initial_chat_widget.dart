import 'package:ai_chat_bot/constants/system_prompt.dart';
import 'package:ai_chat_bot/data/models/ui_model/chat_model.dart';
import 'package:ai_chat_bot/gen/locale_keys.g.dart';
import 'package:ai_chat_bot/presentation/base/ui/base_page.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_cubit.dart';
import 'package:ai_chat_bot/presentation/chat/ui/widgets/chat_bar.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InitialChatWidget extends StatelessWidget {
  const InitialChatWidget({super.key});

  void _handleMessageSubmit(BuildContext context, String message) {
    final chatHistory = [
      ChatModel(message: SystemPrompt().systemPrompt, isLoading: false),
      ChatModel(
        message: OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(message)
          ],
          role: OpenAIChatMessageRole.user,
        ),
        isLoading: false,
      ),
      ChatModel(
        message: OpenAIChatCompletionChoiceMessageModel(
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text('')],
          role: OpenAIChatMessageRole.assistant,
        ),
        isLoading: true,
      ),
    ];
    context.read<ChatCubit>().sendMessage(chatHistory);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Chat',
      bodyForMobile: _buildChatLayout(context, isMobile: true),
      bodyForDesktop: _buildChatLayout(context, isMobile: false),
    );
  }

  Widget _buildChatLayout(BuildContext context, {required bool isMobile}) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16.w, vertical: isMobile ? 0 : 24.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocaleKeys.helloUser.tr(),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              SizedBox(height: 8.h),
              Text(LocaleKeys.howCanIHelp.tr(),
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center),
              SizedBox(height: 40.h),
              if (!isMobile) ...[
                ChatBarWidget(
                  onStop: () {},
                  isStreaming: false,
                  onSubmit: (msg) => _handleMessageSubmit(context, msg),
                ),
                SizedBox(height: 20.h),
              ],
              _buildButtonGrid(),
            ],
          ),
        ),
        if (isMobile)
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: ChatBarWidget(
              onStop: () {},
              isStreaming: false,
              onSubmit: (msg) => _handleMessageSubmit(context, msg),
            ),
          ),
      ],
    );
  }

  Widget _buildButtonGrid() {
    final buttons = [
      (LocaleKeys.deepSearch.tr(), Icons.search),
      (LocaleKeys.think.tr(), Icons.lightbulb),
      (LocaleKeys.research.tr(), Icons.manage_search),
      (LocaleKeys.howTo.tr(), Icons.auto_stories),
      (LocaleKeys.analyze.tr(), Icons.bar_chart),
      (LocaleKeys.createImages.tr(), Icons.image),
      (LocaleKeys.code.tr(), Icons.code),
    ];
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: buttons.map((btn) => _buildButton(btn.$1, btn.$2)).toList(),
    );
  }

  Widget _buildButton(String text, IconData icon) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black54,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () {},
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(text),
      ),
    );
  }
}
