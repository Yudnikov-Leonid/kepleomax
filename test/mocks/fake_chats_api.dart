import 'package:kepleomax/core/network/apis/chats/chats_api.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:retrofit/dio.dart';

class FakeChatsApi implements ChatsApi {
  HttpResponse<ChatsResponse>? getChatsData;

  /// test methods
  void getChatsMustReturn(HttpResponse<ChatsResponse> value) {
    getChatsData = value;
  }

  /// overrides
  @override
  Future<HttpResponse<ChatsResponse>> getChats() async {
    if (getChatsData == null) throw Exception('getChatsData is not initialized. Call getChatsShouldReturn first');

    return getChatsData!;
  }

  @override
  Future<HttpResponse<ChatResponse>> getChatWithUser({required int otherUserId}) {
    // TODO: implement getChatWithUser
    throw UnimplementedError();
  }

  @override
  Future<HttpResponse<ChatResponse>> getChatWithId({required int chatId}) {
    // TODO: implement getChatWithId
    throw UnimplementedError();
  }
}