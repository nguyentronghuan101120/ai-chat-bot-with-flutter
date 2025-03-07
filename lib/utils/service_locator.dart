import 'package:ai_chat_bot/data/repositories/chat_repository_impl.dart';
import 'package:ai_chat_bot/domain/chat_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:ai_chat_bot/data/data_provider/chat_data_provider.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  void setupLocator() {
    _setupDataProvider();
    _setupRepository();
  }

  void _setupDataProvider() {
    getIt.registerLazySingleton<ChatDataProvider>(
      () => ChatDataProvider(),
    );
  }

  void _setupRepository() {
    getIt.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(getIt<ChatDataProvider>()),
    );
  }
}
