import 'dart:convert';

import 'package:kepleomax/core/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider {
  final SharedPreferences prefs;

  UserProvider({required this.prefs});

  static const _key = 'user_info_key';

  Future<void> setNewUser(User? user) async {
    if (user == null) {
      await deleteUser();
      return;
    }

    final userInfo = jsonEncode(user.toJson());
    print('setNewUser: $userInfo');

    await prefs.setString(_key, userInfo);
  }

  Future<void> deleteUser() async {
    await prefs.remove(_key);
  }

  Future<User?> getSavedUser() async {
    final userInfo = prefs.getString(_key);
    print('getSavedUser: $userInfo');

    if (userInfo == null) return null;

    return User.fromJson(jsonDecode(userInfo));
  }
}
