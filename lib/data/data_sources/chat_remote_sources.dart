import 'package:ai_chat_bot/data/models/requests/cancel_chat_request.dart';
import 'package:ai_chat_bot/data/models/requests/chat_request.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'chat_remote_sources.g.dart';

@RestApi()
abstract class ChatRemoteSources {
  factory ChatRemoteSources(Dio dio, {String? baseUrl}) = _ChatRemoteSources;

  @POST('/chat/stream')
  @DioResponseType(ResponseType.stream)
  Future<dynamic> streamChat(
      @Body() ChatRequest request, @CancelRequest() CancelToken? cancelToken);

  @POST('/chat/cancel')
  Future<void> cancelChat(@Body() CancelChatRequest request);
}
