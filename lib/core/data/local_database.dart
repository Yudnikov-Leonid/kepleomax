import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  late Database _db;

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
        await db.execute('CREATE INDEX messages_chat_id_index ON messages (chat_id)');
        await db.execute('CREATE INDEX messages_row_updated_at_index ON messages (row_updated_at)');
      },
      onUpgrade: (db, oldV, newV) async {},
    );
    _db.delete(
      'messages',
      where: r'row_updated_at < $1',
      whereArgs: [
        DateTime.now().add(const Duration(days: -2)).millisecondsSinceEpoch,
      ],
    ).ignore();
  }

  Future<List<MessageDto>> getMessagesByChatId(
    int chatId, {
    int limit = 25,
    int offset = 0,
  }) async {
    final query = await _db.query(
      'messages',
      where: r'chat_id = $1',
      whereArgs: [chatId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    final mapped = query.map(MessageDto.fromJson);
    return mapped.toList();
  }

  Future<void> insertMessage(MessageDto message) async {
    final json = Map.of(message.toJson());
    json.remove('user');
    json['is_read'] = json['is_read'] == true ? 1 : 0;
    json['is_current_user'] = json['is_current_user'] == true ? 1 : 0;
    json['row_updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await _db.insert('messages', json, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> readMessages(List<int> ids) async {
    for (final id in ids) {
      await _db.update(
        'messages',
        {'is_read': 1},
        where: r'id = $1',
        whereArgs: [id],
      );
    }
  }

  Future<void> updateMessage(MessageDto message) async {
    await _db.update('messages', message.toJson());
  }

  Future<void> deleteMessage(MessageDto message) async {
    await _db.delete('messages', where: r'id = $1', whereArgs: [message.id]);
  }
}
