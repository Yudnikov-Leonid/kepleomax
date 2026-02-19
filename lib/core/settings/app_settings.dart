import 'package:kepleomax/core/data/local_data_sources/local_database_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppSettings {
  Future<void> resetDatabase();

  Future<void> setHighlightCacheMessages(bool value);

  bool get highlightCacheMessages;
}

class AppSettingsImpl implements AppSettings {
  final SharedPreferences _prefs;

  AppSettingsImpl({required SharedPreferences prefs}) : _prefs = prefs;

  static const _highlightCacheMessagesKey = '__highlight_cache_messages_key__';

  @override
  Future<void> resetDatabase() => LocalDatabaseManager.reset();

  @override
  Future<void> setHighlightCacheMessages(bool value) async {
    await _prefs.setBool(_highlightCacheMessagesKey, value);
  }

  @override
  bool get highlightCacheMessages =>
      _prefs.getBool(_highlightCacheMessagesKey) ?? false;
}
