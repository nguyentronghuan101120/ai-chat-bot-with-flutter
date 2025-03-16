import 'package:ai_chat_bot/data/data_provider/image_data_provider.dart';
import 'package:ai_chat_bot/domain/image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageDataProvider _imageDataProvider;

  ImageRepositoryImpl(this._imageDataProvider);

  @override
  Future<String> generateImage(String prompt) {
    return _imageDataProvider.generateImage(prompt);
  }
}
