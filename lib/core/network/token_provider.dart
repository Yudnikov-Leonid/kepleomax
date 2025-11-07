import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenProvider {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  TokenProvider({required SharedPreferences prefs, required FlutterSecureStorage secureStorage}) : _secureStorage = secureStorage, _prefs = prefs;

  static const _accessTokenKey = 'access_token_key';
  static const _refreshTokenKey = 'refresh_token_key';

  void saveAccessToken(String token) {
    _prefs.setString(_accessTokenKey, token);
  }

  String? getAccessToken() => _prefs.getString(_accessTokenKey);

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: _refreshTokenKey);

  Future<void> clearAll() async {
    _prefs.remove(_accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
