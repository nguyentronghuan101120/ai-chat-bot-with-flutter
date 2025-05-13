import 'package:ai_chat_bot/domain/repositories/local_repository.dart';
import 'package:ai_chat_bot/gen/locale_keys.g.dart';
import 'package:ai_chat_bot/presentation/chat/ui/chat_page.dart';
import 'package:ai_chat_bot/presentation/common/loading_widget.dart';
import 'package:ai_chat_bot/utils/service_locator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ai_chat_bot/data/models/local_models/chat_local.dart';

class DrawerSection extends StatefulWidget {
  const DrawerSection({super.key});

  @override
  State<DrawerSection> createState() => _DrawerSectionState();
}

class _DrawerSectionState extends State<DrawerSection> {
  List<ChatLocal> _chatHistories = [];

  final _repo = getIt<LocalRepository>();

  @override
  void initState() {
    super.initState();
    _loadChatHistories();
  }

  Future<void> _loadChatHistories() async {
    _chatHistories = _repo.getChatHistoriesFromLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Row(
            children: [
              Flexible(
                child: ListTile(
                  title: Text(LocaleKeys.newChat.tr()),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ChatPage()),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(LocaleKeys.clearAllChats.tr()),
                        content: Text(
                          LocaleKeys.areYouSureYouWantToDiscardYourChanges.tr(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(LocaleKeys.cancel.tr()),
                          ),
                          TextButton(
                            onPressed: () {
                              _repo.clearAll();
                              setState(() {
                                _chatHistories = [];
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text(LocaleKeys.ok.tr()),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.delete,
                ),
              )
            ],
          ),
          Divider(),
          ..._chatHistories.map(
            (chat) => chat.chatSummary != null
                ? ListTile(
                    title: Text(chat.chatSummary ?? ''),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            initialChatSessionId: chat.chatSessionId,
                          ),
                        ),
                      );
                    },
                  )
                : LoadingWidget(),
          ),
        ],
      ),
    );
  }
}
