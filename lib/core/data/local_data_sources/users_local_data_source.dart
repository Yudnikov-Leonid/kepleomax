import 'dart:convert';

import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

abstract class UsersLocalDataSource {
  Future<void> insert(UserDto user);

  Future<void> insertAll(Iterable<UserDto> users);

  // Future<UserDto?> getUserById(int id);

  User? getCurrentUser();

  Future<void> setCurrentUser(User? user);
}

class UsersLocalDataSourceImpl implements UsersLocalDataSource {
  final Database _database;
  final SharedPreferences _prefs;

  UsersLocalDataSourceImpl({
    required Database database,
    required SharedPreferences prefs,
  }) : _database = database,
       _prefs = prefs;

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

  static const _currentUserKey = '__current_user_info_key__';

  @override
  User? getCurrentUser() {
    final userInfo = _prefs.getString(_currentUserKey);

    if (userInfo == null) return null;

    return User.fromJson(jsonDecode(userInfo));
  }

  @override
  Future<void> setCurrentUser(User? user) async {
    if (user == null) {
      await _prefs.remove(_currentUserKey);
      return;
    }

    final userInfo = jsonEncode(user.toJson());

    await _prefs.setString(_currentUserKey, userInfo);
  }

  // @override
  // Future<UserDto?> getUserById(int id) async {
  //   final query = await _database.query('users', where: 'id = ?', whereArgs: [id]);
  //   if (query.isEmpty) return null;
  //   return UserDto.fromJson(query.first);
  // }
}
