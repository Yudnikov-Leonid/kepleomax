import 'package:kepleomax/core/network/common/user_dto.dart';
import 'package:sqflite/sqflite.dart';

abstract class IUsersLocalDataSource {
  Future<void> insert(UserDto user);

  Future<UserDto?> getUserById(int id);
}

class UsersLocalDataSource implements IUsersLocalDataSource {
  final Database _database;

  UsersLocalDataSource({required Database database}) : _database = database;

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
  Future<UserDto?> getUserById(int id) async {
    final query = await _database.query('users', where: 'id = ?', whereArgs: [id]);
    if (query.isEmpty) return null;
    return UserDto.fromJson(query.first);
  }
}
