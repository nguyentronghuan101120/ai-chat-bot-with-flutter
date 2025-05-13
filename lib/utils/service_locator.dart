import 'package:ai_chat_bot/data/data_sources/chat_remote_sources.dart';
import 'package:ai_chat_bot/data/data_sources/file_process_sources.dart';
import 'package:ai_chat_bot/data/repositories/chat_repository_impl.dart';
import 'package:ai_chat_bot/data/repositories/file_repository_impl.dart';
import 'package:ai_chat_bot/data/repositories/local_repository_impl.dart';
import 'package:ai_chat_bot/domain/repositories/chat_repository.dart';
import 'package:ai_chat_bot/domain/repositories/file_repository.dart';
import 'package:ai_chat_bot/domain/repositories/local_repository.dart';
import 'package:ai_chat_bot/utils/dio.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  void setupLocator() {
    getIt.registerLazySingleton<DioClient>(() => DioClient());
    _setupDataProvider(getIt<DioClient>().dio);
    _setupRepository();
  }

  void _setupDataProvider(Dio dio) {
    getIt.registerLazySingleton<ChatRemoteSources>(
      () => ChatRemoteSources(dio),
    );
    getIt.registerLazySingleton<FileProcessSources>(
      () => FileProcessSources(dio),
    );
  }
}

void _setupRepository() {
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(getIt<ChatRemoteSources>()),
  );
  getIt.registerLazySingleton<FileRepository>(
    () => FileRepositoryImpl(getIt<FileProcessSources>()),
  );
  getIt.registerLazySingleton<LocalRepository>(
    () => LocalRepositoryImpl(),
  );
}
