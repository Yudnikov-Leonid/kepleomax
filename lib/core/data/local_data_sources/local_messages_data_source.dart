import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:sqflite/sqflite.dart';

abstract class IMessagesLocalDataSource {
  Future<List<MessageDto>> getMessagesByChatId(int chatId);

  Future<void> insert(MessageDto message);

  Future<void> insertAll(Iterable<MessageDto> messages);

  Future<void> readMessages(ReadMessagesUpdate data);

  Future<void> update(MessageDto message);

  Future<void> deleteById(int id);

  Future<void> deleteAllByIds(Iterable<int> ids);
}

class MessagesLocalDataSource implements IMessagesLocalDataSource {
  final Database _database;

  MessagesLocalDataSource({required Database database}) : _database = database;

  @override
  Future<List<MessageDto>> getMessagesByChatId(int chatId) async {
    final query = await _database.query(
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
  Future<void> insert(MessageDto message) async {
    await _database.insert(
      'messages',
      message.toLocalJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> insertAll(Iterable<MessageDto> messages) async {
    await _database.transaction((transaction) async {
      for (final message in messages) {
        await transaction.insert(
          'messages',
          message.toLocalJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> readMessages(ReadMessagesUpdate data) async {
    for (final id in data.messagesIds) {
      await _database.update(
        'messages',
        {'is_read': 1},
        where: r'id = ?',
        whereArgs: [id],
      );
    }
  }

  @override
  Future<void> update(MessageDto message) async {
    await _database.update('messages', message.toJson());
  }

  @override
  Future<void> deleteById(int id) async {
    await _database.delete('messages', where: r'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAllByIds(Iterable<int> ids) async {
    await _database.transaction((transaction) async {
      for (final id in ids) {
        await transaction.delete('messages', where: r'id = ?', whereArgs: [id]);
      }
    });
  }
}
