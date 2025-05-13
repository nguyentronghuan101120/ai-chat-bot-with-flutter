import 'package:ai_chat_bot/constants/enum.dart';
import 'package:ai_chat_bot/data/models/local_models/chat_history.dart';
import 'package:ai_chat_bot/data/models/local_models/chat_local.dart';
import 'package:ai_chat_bot/data/models/local_models/file_info.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<void> hiveRegister() async {
    Hive.registerAdapter(ChatLocalAdapter());
    Hive.registerAdapter(ChatHistoryAdapter());
    Hive.registerAdapter(ChatRoleAdapter());
    Hive.registerAdapter(FileInfoAdapter());

    await Hive.openBox<ChatLocal>("chatHistories");
  }
}
