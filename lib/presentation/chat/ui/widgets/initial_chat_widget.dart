import 'package:ai_chat_bot/constants/system_prompt.dart';
import 'package:ai_chat_bot/data/models/ui_model/chat_model.dart';
import 'package:ai_chat_bot/gen/locale_keys.g.dart';
import 'package:ai_chat_bot/presentation/base/ui/base_page.dart';
import 'package:ai_chat_bot/presentation/chat/cubit/chat_cubit.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InitialChatWidget extends StatelessWidget {
  const InitialChatWidget({super.key});

  void _handleMessageSubmit(BuildContext context, String message) {
    final chatHistory = [
      ChatModel(
        message: SystemPrompt().systemPrompt,
        isLoading: false,
      ),
      ChatModel(
        message: OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
          ],
          role: OpenAIChatMessageRole.user,
        ),
        isLoading: false,
      ),
      ChatModel(
        message: OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(''),
          ],
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
      bodyForMobile: _buildBody(context),
      bodyForDesktop: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.helloUser.tr(),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  LocaleKeys.howCanIHelp.tr(),
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                Container(
                  constraints: BoxConstraints(maxWidth: 768),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textEditingController,
                            decoration: InputDecoration(
                              hintText: LocaleKeys.whatDoYouWantToKnow.tr(),
                              hintStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _handleMessageSubmit(
                                    context, textEditingController.text);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_upward,
                              color: Colors.white),
                          onPressed: () {
                            if (textEditingController.text.isNotEmpty) {
                              _handleMessageSubmit(
                                  context, textEditingController.text);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Wrap(
                  spacing: 12.w,
                  children: [
                    _buildButton(LocaleKeys.deepSearch.tr(), Icons.search),
                    _buildButton(LocaleKeys.think.tr(), Icons.lightbulb),
                    _buildButton(LocaleKeys.research.tr(), Icons.manage_search),
                    _buildButton(LocaleKeys.howTo.tr(), Icons.auto_stories),
                    _buildButton(LocaleKeys.analyze.tr(), Icons.bar_chart),
                    _buildButton(LocaleKeys.createImages.tr(), Icons.image),
                    _buildButton(LocaleKeys.code.tr(), Icons.code),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButton(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(2),
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
