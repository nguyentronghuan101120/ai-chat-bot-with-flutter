import 'package:ai_chat_bot/presentation/base/ui/widgets/drawer_section.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class BasePage extends StatefulWidget {
  const BasePage(
      {super.key,
      this.title,
      required this.bodyForMobile,
      required this.bodyForDesktop});

  final String? title;

  final Widget bodyForMobile;
  final Widget bodyForDesktop;

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  String buildVersion = '';
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String version = packageInfo.version;

      setState(() {
        buildVersion = version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerSection(),
      appBar: AppBar(
        title: Text(widget.title ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 768) {
                    return widget.bodyForDesktop;
                  } else {
                    return widget.bodyForMobile;
                  }
                },
              ),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Text('Version: $buildVersion')),
          ],
        ),
      ),
    );
  }
}
