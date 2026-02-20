import 'package:kepleomax/core/network/token_provider.dart';

class MockTokenProvider implements TokenProvider {
  @override
  Future<String?> getAccessToken({
    bool refreshIfNeeded = true,
    Function? onLogoutCallback,
  }) async => 'mock_access_token';

  @override
  Future<String?> getRefreshToken() async => 'mock_refresh_token';

  @override
  Future<void> saveAccessToken(String token) async {}

  @override
  Future<void> saveRefreshToken(String token) async {}

  @override
  Future<void> clearAll() async {}
}
