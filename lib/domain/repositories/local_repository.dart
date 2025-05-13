import 'package:ai_chat_bot/data/models/local_models/chat_local.dart';
import 'package:ai_chat_bot/domain/entities/chat_entity.dart';

abstract class LocalRepository {
  Future<void> saveChatToLocal({
    required List<ChatEntity> chatHistories,
    String? chatSessionId,
    String? chatSummary,
  });

  List<ChatLocal> getChatHistoriesFromLocal();

  List<ChatEntity> getChatHistoryFromLocal(String chatSessionId);

  Future<void> clearAll();
}
