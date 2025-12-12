import 'package:collection/collection.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:sqflite/sqflite.dart';

abstract class ILocalMessagesDatabase {
  Future<List<MessageDto>> getMessagesByChatId(
    int chatId, {
    int limit = 25,
    int offset = 0,
  });

  Future<void> insertMessage(MessageDto message);

  Future<void> readMessages(List<int> ids);

  Future<void> updateMessage(MessageDto message);

  Future<void> deleteMessage(MessageDto message);
}

abstract class ILocalChatsDatabase {
  Future<List<ChatDto>> getChats();

  Future<ChatDto?> getChat(int chatId);

  Future<void> clearAndInsertChats(List<ChatDto> chats);

  Future<void> insertChat(ChatDto chat);

  Future<void> updateChat(ChatDto chat);
}

class LocalDatabase implements ILocalMessagesDatabase, ILocalChatsDatabase {
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
          other_user_id INT, 
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
          last_message TEXT,
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

  Future<void> clear() async {
    await _db.delete('messages');
    await _db.delete('chats');
  }

  /// chats
  @override
  Future<List<ChatDto>> getChats() async {
    final query = await _db.query('chats');
    return query
        .map(ChatDto.fromLocalJson)
        .sorted(
          (a, b) =>
              (b.lastMessage?.createdAt ?? 0) - (a.lastMessage?.createdAt ?? 0),
        )
        .toList();
  }

  @override
  Future<ChatDto?> getChat(int chatId) async {
    final query = await _db.query('chats', where: 'id = ?', whereArgs: [chatId]);
    return query.map(ChatDto.fromLocalJson).firstOrNull;
  }

  @override
  Future<void> clearAndInsertChats(List<ChatDto> chats) async {
    await _db.delete('chats');
    for (final chat in chats) {
      _db.insert('chats', chat.toLocalJson());
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
    int offset = 0,
  }) async {
    final query = await _db.query(
      'messages',
      where: r'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return query.map(MessageDto.fromJson).toList();
  }

  @override
  Future<void> insertMessage(MessageDto message) async {
    final json = Map.of(message.toJson());
    json.remove('user');
    json['is_read'] = json['is_read'] == true ? 1 : 0;
    json['is_current_user'] = json['is_current_user'] == true ? 1 : 0;
    json['row_updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await _db.insert('messages', json, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> readMessages(List<int> ids) async {
    for (final id in ids) {
      await _db.update(
        'messages',
        {'is_read': 1},
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
  Future<void> deleteMessage(MessageDto message) async {
    await _db.delete('messages', where: r'id = ?', whereArgs: [message.id]);
  }
}
