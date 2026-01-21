import 'dart:async';

import 'package:collection/collection.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/user.dart';

class FakeChatsRepository implements IChatsRepository {
  final _getChatsController = StreamController<List<Chat>>();
  late final _getChatsIterator = StreamIterator(_getChatsController.stream);
  final _getChatWithIdController = StreamController<Chat>();
  late final _getChatWithIdIterator = StreamIterator(
    _getChatWithIdController.stream,
  );

  /// tests methods
  void getChatsReturn(List<Chat> value) {
    _getChatsController.add(value);
  }

  void getChatsThrowError() {
    _getChatsController.addError(_errorList);
  }

  void getChatWithIdReturn(Chat value) {
    _getChatWithIdController.add(value);
  }

  /// overrides
  @override
  // TODO: implement chatsUpdatesStream
  Stream<List<Chat>> get chatsUpdatesStream => throw UnimplementedError();

  @override
  Future<Chat?> getChatWithId(int chatId) async {
    final isMoveNext = await _getChatWithIdIterator.moveNext();
    if (!isMoveNext) throw Exception('getChatsWithIdStream is closed');
    return _getChatWithIdIterator.current.copyWith(id: chatId);
  }

  @override
  Future<Chat?> getChatWithUser(int otherUserId) {
    // TODO: implement getChatWithUser
    throw UnimplementedError();
  }

  @override
  Future<List<Chat>> getChats() async {
    final isMoveNext = await _getChatsIterator.moveNext();
    if (!isMoveNext) throw Exception('getChatsStream is closed');
    final list = _getChatsIterator.current;
    if (const ListEquality().equals(list, _errorList)) {
      throw Exception('exception from repository');
    }
    return list;
  }

  @override
  Future<List<Chat>> getChatsFromCache() {
    // TODO: implement getChatsFromCache
    throw UnimplementedError();
  }

  @override
  Future<void> updateLocalChat(Chat chat) async {
    // TODO: implement updateLocalChat
  }

  @override
  Future<Chat?> getChatWithIdFromCache(int chatId) {
    // TODO: implement getChatWithIdFromCache
    throw UnimplementedError();
  }

  @override
  Future<Chat?> getChatWithUserFromCache(int otherUserId) {
    // TODO: implement getChatWithUserFromCache
    throw UnimplementedError();
  }
}

const _errorList = [
  Chat(
    id: -111,
    otherUser: User(id: -1, username: '', profileImage: '', isCurrent: false),
    lastMessage: null,
    unreadCount: 12,
  ),
];
