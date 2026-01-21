import 'package:flutter_test/flutter_test.dart';
import 'package:kepleomax/core/data/local/local_database.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';

class FakeLocalChatsDatabase implements ILocalChatsDatabase {
  final List<List<ChatDto>> _clearAndInsertChatsCalls = [];
  final List<ChatDto> _insertChatCalls = [];
  List<ChatDto>? _getChatsReturnValue;

  /// test methods
  void checkClearAndInsertChatsCalledTimes(int value) {
    expect(_clearAndInsertChatsCalls.length, value);
  }

  void checkClearAndInsertChatsCalledWith(List<ChatDto> value) {
    expect(_clearAndInsertChatsCalls.last, value);
  }

  void getChatsMustReturn(List<ChatDto> value) {
    _getChatsReturnValue = value;
  }

  void checkInsertChatCalledTimes(int value) {
    expect(_insertChatCalls.length, value);
  }

  void checkInsertChatCalledWith(ChatDto value) {
    expect(_insertChatCalls.last, value);
  }

  /// overrides
  @override
  Future<void> clearAndInsertChats(List<ChatDto> chats) async {
    _clearAndInsertChatsCalls.add(chats);
  }

  @override
  Future<ChatDto?> getChat(int chatId) {
    // TODO: implement getChat
    throw UnimplementedError();
  }

  @override
  Future<List<ChatDto>> getChats() async {
    if (_getChatsReturnValue == null) throw Exception('getChatsReturnValue is not initialized. Call getChatsMustReturn first');

    return _getChatsReturnValue!;
  }

  @override
  Future<void> insertChat(ChatDto chat) async {
    _insertChatCalls.add(chat);
  }

  @override
  Future<void> updateChat(ChatDto chat) {
    // TODO: implement updateChat
    throw UnimplementedError();
  }
}
