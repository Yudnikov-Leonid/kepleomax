import 'package:kepleomax/core/network/common/user_dto.dart';
import 'package:sqflite/sqflite.dart';

abstract class UsersLocalDataSource {
  Future<void> insert(UserDto user);

  Future<void> insertAll(Iterable<UserDto> users);

  Future<UserDto?> getUserById(int id);
}

class UsersLocalDataSourceImpl implements UsersLocalDataSource {
  final Database _database;

  UsersLocalDataSourceImpl({required Database database}) : _database = database;

  @override
  Future<void> insert(UserDto user) async {
    if (user.isCurrent) return;

    await _database.insert(
      'users',
      user.toLocalJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> insertAll(Iterable<UserDto> users) async {
    await _database.transaction((ts) async {
      for (final user in users) {
        await ts.insert(
          'users',
          user.toLocalJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<UserDto?> getUserById(int id) async {
    final query = await _database.query('users', where: 'id = ?', whereArgs: [id]);
    if (query.isEmpty) return null;
    return UserDto.fromJson(query.first);
  }
}
