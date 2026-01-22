import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:sqflite/sqflite.dart';

abstract class IChatsLocalDataSource {
  Future<List<ChatDto>> getChats();

  Future<ChatDto?> getChat(int chatId);

  Future<void> clearAndInsertChats(Iterable<ChatDto> chats);

  Future<void> insertChat(ChatDto chat);

  Future<void> increaseUnreadCountBy1(int chatId);

  Future<void> decreaseUnreadCount(int chatId, int amount);

  Future<void> updateChat(ChatDto chat);
}

class ChatsLocalDataSource implements IChatsLocalDataSource {
  final Database _database;

  ChatsLocalDataSource({required Database database}) : _database = database;

  @override
  Future<ChatDto?> getChat(int chatId) async {
    final query = await _database.query('chats', where: 'id = ?', whereArgs: [chatId]);
    return query.map(ChatDto.fromLocalJson).firstOrNull;
  }

  @override
  Future<List<ChatDto>> getChats() async {
    final query = await _database.query('chats');

    final result = <ChatDto>[];
    for (var chat in query) {
      final lastMessage = await _database.query(
        'messages',
        limit: 1,
        where: 'chat_id = ?',
        whereArgs: [chat['id']],
        orderBy: 'created_at DESC',
      );

      if (lastMessage.isNotEmpty) {
        chat = Map.from(chat);
        chat['last_message'] = jsonEncode(lastMessage[0]);
      }
      result.add(ChatDto.fromLocalJson(chat));
    }

    return result.sorted(
          (a, b) => (b.lastMessage?.createdAt ?? 0) - (a.lastMessage?.createdAt ?? 0),
    );
  }

  @override
  Future<void> clearAndInsertChats(Iterable<ChatDto> chats) async {
    await _database.delete('chats');
    for (final chat in chats) {
      await _database.insert('chats', chat.toLocalJson());
    }
  }

  @override
  Future<void> insertChat(ChatDto chat) async {
    await _database.insert(
      'chats',
      chat.toLocalJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  @override
  Future<void> updateChat(ChatDto chat) async {
    await _database.update(
      'chats',
      chat.toLocalJson(),
      where: 'id = ?',
      whereArgs: [chat.id],
    );
  }
}