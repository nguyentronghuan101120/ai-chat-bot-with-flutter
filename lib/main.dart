import 'package:ai_chat_bot/presentation/base/ui/base_page.dart';
import 'package:ai_chat_bot/presentation/chat/ui/chat_page.dart';
import 'package:ai_chat_bot/utils/open_ai_client.dart';
import 'package:ai_chat_bot/utils/service_locator.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  OpenAIClient.initClient();
  ServiceLocator().setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenAI Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BasePage(
        title: 'Chat',
        body: ChatPage(),
      ),
    );
  }
}
