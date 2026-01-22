import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:sqflite/sqflite.dart';

abstract class IChatsLocalDataSource {
  Future<List<ChatDto>> getChats();

  Future<ChatDto?> getChat(int chatId);

  Future<void> clearAndInsertChats(Iterable<ChatDto> chats);

  Future<void> insert(ChatDto chat);

  Future<void> update(ChatDto chat);

  Future<void> increaseUnreadCountBy1(int chatId);

  Future<void> decreaseUnreadCount(int chatId, int amount);
}

class ChatsLocalDataSource implements IChatsLocalDataSource {
  final Database _database;

  ChatsLocalDataSource({required Database database}) : _database = database;

  @override
  Future<ChatDto?> getChat(int chatId) async {
    final query = await _database.query(
      'chats',
      where: 'id = ?',
      whereArgs: [chatId],
    );

    if (query.isEmpty) return null;

    final otherUser = await _database.query(
      'users',
      where: 'id = ?',
      whereArgs: [query.first['other_user_id']],
    );
    if (otherUser.isEmpty)
      throw Exception('otherUser in cache not found'); //todo what to return?
    final newJson = Map<String, dynamic>.from(query.first);
    newJson['other_user_id'] = null;
    newJson['other_user'] = otherUser.firstOrNull;
    return ChatDto.fromJson(newJson);
  }

  @override
  Future<List<ChatDto>> getChats() async {
    final query = await _database.query('chats');

    final result = <ChatDto>[];
    for (var chat in query) {
      chat = Map.from(chat);

      final lastMessage = await _database.query(
        'messages',
        limit: 1,
        where: 'chat_id = ?',
        whereArgs: [chat['id']],
        orderBy: 'created_at DESC',
      );
      if (lastMessage.isNotEmpty) {
        chat['last_message'] = jsonEncode(lastMessage[0]);
      }

      final otherUser = await _database.query(
        'users',
        where: 'id = ?',
        whereArgs: [chat['other_user_id']],
      );
      if (otherUser.isEmpty)
        throw Exception('otherUser in cache not found'); //todo what to return?
      chat['other_user_id'] = null;
      chat['other_user'] = otherUser.first;

      result.add(ChatDto.fromLocalJson(chat));
    }

    return result.sorted(
      (a, b) => (b.lastMessage?.createdAt ?? 0) - (a.lastMessage?.createdAt ?? 0),
    );
  }

  @override
  Future<void> insert(ChatDto chat) async {
    await _database.insert(
      'chats',
      chat.toLocalJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(ChatDto chat) async {
    await _database.update(
      'chats',
      chat.toLocalJson(),
      where: 'id = ?',
      whereArgs: [chat.id],
    );
  }

  @override
  Future<void> clearAndInsertChats(Iterable<ChatDto> chats) async {
    await _database.delete('chats');
    _database.transaction((transaction) async {
      for (final chat in chats) {
        await transaction.insert('chats', chat.toLocalJson());
      }
    });
  }

  @override
  Future<void> increaseUnreadCountBy1(int chatId) async {
    await _database.rawUpdate(
      'UPDATE chats SET unread_count = unread_count + 1 WHERE id = ?',
      [chatId],
    );
  }

  @override
  Future<void> decreaseUnreadCount(int chatId, int amount) async {
    await _database.rawUpdate(
      'UPDATE chats SET unread_count = unread_count - ? WHERE id = ?',
      [amount, chatId],
    );
  }
}
