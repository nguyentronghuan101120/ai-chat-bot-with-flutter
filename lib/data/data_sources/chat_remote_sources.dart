import 'package:ai_chat_bot/data/models/requests/chat_request.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'chat_remote_sources.g.dart';

@RestApi()
abstract class ChatRemoteSources {
  factory ChatRemoteSources(Dio dio, {String? baseUrl}) = _ChatRemoteSources;

  @POST('/chat/stream')
  @DioResponseType(ResponseType.stream)
  Future<Response> streamChat(@Body() ChatRequest request);
}
