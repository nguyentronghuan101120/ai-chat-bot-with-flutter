import 'package:ai_chat_bot/data/models/local_models/chat_history.dart';
import 'package:ai_chat_bot/data/models/local_models/chat_local.dart';
import 'package:ai_chat_bot/data/models/local_models/file_info.dart';
import 'package:ai_chat_bot/domain/entities/chat_entity.dart';
import 'package:ai_chat_bot/domain/repositories/local_repository.dart';
import 'package:ai_chat_bot/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

class LocalRepositoryImpl extends LocalRepository {
  final chatBox = Hive.box<ChatLocal>('chatHistories');

  @override
  Future<void> saveChatToLocal({
    required List<ChatEntity> chatHistories,
    String? chatSessionId,
    String? chatSummary,
  }) async {
    final chatModel = ChatLocal(
      chatSummary: chatSummary,
      chatSessionId: chatSessionId,
      chatHistories: chatHistories
          .map(
            (e) => ChatHistory(
              message: e.message,
              role: e.role,
              files: e.files
                  ?.map(
                    (file) => FileInfo(
                      fileName: file.name,
                      filePath: file.path ?? '',
                      fileSize: file.size,
                      mimeType: file.extension ?? '',
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
    final existingChat = chatBox.values
        .firstWhereOrNull((chat) => chat.chatSessionId == chatSessionId);
    if (existingChat != null) {
      final key = chatBox.keyAt(existingChat.key);
      chatBox.put(key, chatModel);
    } else {
      await chatBox.add(chatModel);
    }
  }

  @override
  List<ChatLocal> getChatHistoriesFromLocal() {
    return chatBox.values.toList();
  }

  @override
  List<ChatEntity> getChatHistoryFromLocal(String chatSessionId) {
    final chat = chatBox.values
        .firstWhereOrNull((e) => e.chatSessionId == chatSessionId);
    if (chat == null) {
      throw Exception(LocaleKeys.dataNotFound.tr());
    }

    final chatHistoriesEntity = chat.chatHistories
        .map(
          (e) => ChatEntity(
            message: e.message,
            role: e.role,
            isLoading: false,
            files: e.files
                ?.map((e) => PlatformFile(name: e.fileName, size: e.fileSize))
                .toList(),
          ),
        )
        .toList();

    return chatHistoriesEntity;
  }

  @override
  Future<void> clearAll() async {
    await chatBox.clear();
  }
}
