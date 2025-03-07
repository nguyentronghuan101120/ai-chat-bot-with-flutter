import 'package:dart_openai/dart_openai.dart';

class OpenAIClient {
  static initClient() {
    OpenAI.apiKey = '';
    OpenAI.baseUrl = 'http://127.0.0.1:1234';
  }
}
