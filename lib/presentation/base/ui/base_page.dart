import 'package:ai_chat_bot/presentation/base/ui/widgets/drawer_section.dart';
import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  const BasePage(
      {super.key,
      this.title,
      required this.bodyForMobile,
      required this.bodyForDesktop});

  final String? title;

  final Widget bodyForMobile;
  final Widget bodyForDesktop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerSection(),
      appBar: AppBar(
        title: Text(title ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 768) {
                return bodyForDesktop;
              } else {
                return bodyForMobile;
              }
            },
          ),
        ),
      ),
    );
  }
}
