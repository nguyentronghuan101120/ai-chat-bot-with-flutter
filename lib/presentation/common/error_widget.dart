import 'package:ai_chat_bot/presentation/chat/ui/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseErrorWidget extends StatelessWidget {
  const BaseErrorWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SelectableText(message),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ChatPage(),
                  ),
                );
              },
              child: const Text('Reload'),
            ),
          ],
        ),
      ),
    );
  }
}
