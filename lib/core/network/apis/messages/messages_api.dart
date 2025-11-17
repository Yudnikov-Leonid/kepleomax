import 'package:dio/dio.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:retrofit/retrofit.dart';

part 'messages_api.g.dart';

@RestApi()
abstract class MessagesApi {
  factory MessagesApi(Dio dio, String baseUrl) =>
      _MessagesApi(dio, baseUrl: '$baseUrl/api/messages');

  @GET('/')
  Future<HttpResponse<MessagesResponse>> getMessages({
    @Query('chatId') required int chatId,
    @Query('limit') required int limit,
    @Query('offset') required int offset,
  });
}
