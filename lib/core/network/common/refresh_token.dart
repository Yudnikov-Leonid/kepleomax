import 'package:dio/dio.dart';
import 'package:flutter/animation.dart';
import 'package:kepleomax/main.dart';

/// this class only get a new token, but doesn't save it to the local storage
class RefreshToken {
  final VoidCallback? _logout;
  final Dio? _dio;

  RefreshToken({void Function()? logout, required Dio? dio})
    : _dio = dio,
      _logout = logout;

  Future<String?> refreshToken(String refreshToken) async {
    try {
      /// because current dio is locked
      final dio = _dio ?? Dio(BaseOptions(validateStatus: (_) => true));

      final response = await dio.post(
        '${flavor.baseUrl}/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        logger.e('Forbidden to refresh token: ${response.statusCode}');
        _logout?.call();
        return null;
      }

      if (response.statusCode == 200) {
        return response.data['accessToken'];
      } else {
        throw Exception('Failed to refreshToken: ${response.statusCode}, $response');
      }
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      return null;
    }
  }
}
