import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:sqflite/sqflite.dart';

abstract class ILocalMessagesDatabase {
  Future<List<MessageDto>> getMessagesByChatId(
    int chatId, {
    int limit = 25,
    int? cursor,
  });

  Future<void> insertMessage(MessageDto message);

  Future<void> readMessages(ReadMessagesUpdate data);

  Future<void> updateMessage(MessageDto message);

  Future<void> deleteMessageById(int id);
}

abstract class ILocalChatsDatabase {
  Future<List<ChatDto>> getChats();

  Future<ChatDto?> getChat(int chatId);

  Future<void> clearAndInsertChats(Iterable<ChatDto> chats);

  Future<void> insertChat(ChatDto chat);

  Future<void> increaseUnreadCountBy1(int chatId);

  Future<void> decreaseUnreadCount(int chatId, int amount);

  Future<void> updateChat(ChatDto chat);
}

abstract class ILocalDatabase
    implements ILocalChatsDatabase, ILocalMessagesDatabase {}

class LocalDatabase implements ILocalDatabase {
  late final Database _db;

  Future<void> init() async {
    _db = await openDatabase(
      'klm_database.db',
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''CREATE TABLE messages (
          id INT PRIMARY KEY, 
          chat_id INT NOT NULL, 
          sender_id INT NOT NULL, 
          is_current_user BIT, 
          message VARCHAR(4000) NOT NULL, 
          is_read BIT DEFAULT FALSE NOT NULL, 
          created_at BIGINT NOT NULL, 
          edited_at BIGINT,
          row_updated_at BIGINT NOT NULL
          )''');
        await db.execute(
          'CREATE INDEX messages_chat_id_index ON messages (chat_id)',
        );
        await db.execute(
          'CREATE INDEX messages_row_updated_at_index ON messages (row_updated_at)',
        );

        await db.execute('''CREATE TABLE chats (
          id INT PRIMARY KEY,
          other_user TEXT NOT NULL,
          unread_count INT NOT NULL   
        )''');
      },
      onUpgrade: (db, oldV, newV) async {},
    );
    _db
        .delete(
          'messages',
          where: r'row_updated_at < ?',
          whereArgs: [
            DateTime.now().add(const Duration(days: -2)).millisecondsSinceEpoch,
          ],
        )
        .ignore();
  }

  Future<void> reset() async {
    await _db.delete('messages');
    await _db.delete('chats');
  }

  /// chats
  @override
  Future<ChatDto?> getChat(int chatId) async {
    final query = await _db.query('chats', where: 'id = ?', whereArgs: [chatId]);
    return query.map(ChatDto.fromLocalJson).firstOrNull;
  }

  @override
  Future<List<ChatDto>> getChats() async {
    final query = await _db.query('chats');

    final result = <ChatDto>[];
    for (var chat in query) {
      final lastMessage = await _db.query(
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
    await _db.delete('chats');
    for (final chat in chats) {
      _db.insert('chats', chat.toLocalJson());
      if (chat.lastMessage != null) {
        insertMessage(chat.lastMessage!);
      }
    }
  }

  @override
  Future<void> insertChat(ChatDto chat) async {
    await _db.insert(
      'chats',
      chat.toLocalJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> increaseUnreadCountBy1(int chatId) async {
    await _db.rawUpdate(
      'UPDATE chats SET unread_count = unread_count + 1 WHERE id = ?',
      [chatId],
    );
  }

  @override
  Future<void> decreaseUnreadCount(int chatId, int amount) async {
    await _db.rawUpdate(
      'UPDATE chats SET unread_count = unread_count - ? WHERE id = ?',
      [amount, chatId],
    );
  }

  @override
  Future<void> updateChat(ChatDto chat) async {
    await _db.update(
      'chats',
      chat.toLocalJson(),
      where: 'id = ?',
      whereArgs: [chat.id],
    );
  }

  /// messages
  @override
  Future<List<MessageDto>> getMessagesByChatId(
    int chatId, {
    int limit = 25,
    int? cursor,
  }) async {
    final query = await _db.query(
      'messages',
      where: r'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'created_at DESC',
      // limit: limit, // TODO
      // offset: offset,
    );
    return query.map((m) => MessageDto.fromJson(m, fromCache: true)).toList();
  }

  @override
  Future<void> insertMessage(MessageDto message) async {
    final json = Map.of(message.toLocalJson());
    json['row_updated_at'] = DateTime.now().millisecondsSinceEpoch;

    await _db.insert('messages', json, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> readMessages(ReadMessagesUpdate data) async {
    for (final id in data.messagesIds) {
      await _db.update(
        'messages',
        // TODO make row_updated_at better way
        {'is_read': 1, 'row_updated_at': DateTime.now().millisecondsSinceEpoch},
        where: r'id = ?',
        whereArgs: [id],
      );
    }
  }

  @override
  Future<void> updateMessage(MessageDto message) async {
    await _db.update('messages', message.toJson());
  }

  @override
  Future<void> deleteMessageById(int id) async {
    await _db.delete('messages', where: r'id = ?', whereArgs: [id]);
  }
}
