import 'package:dio/dio.dart';
import 'package:flutter/animation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';
import 'package:kepleomax/core/network/common/ntp_time.dart';
import 'package:kepleomax/main.dart';
import 'package:synchronized/synchronized.dart';

/// this class only get a new token, but doesn't save it to the local storage
class RefreshToken {
  final VoidCallback? _logout;
  final Dio? _dio;

  RefreshToken({void Function()? logout, required Dio? dio})
    : _dio = dio,
      _logout = logout;

  static final _lock = Lock();

  static String? _cache;

  Future<String?> refreshToken(String refreshToken) => _lock.synchronized(() async {
    if (_cache != null) {
      final isInvalid = (await NTPTime.now()).isAfter(JwtDecoder.getExpirationDate(_cache!));
      if (isInvalid) {
        _cache = null;
      } else {
        return _cache;
      }
      print('refreshToken CACHE');
    }
    print('refreshToken POST');

    try {
      /// because current dio is locked
      final dio = _dio ?? Dio(BaseOptions(validateStatus: (_) => true));

      final response = await dio
          .post(
            '${flavor.baseUrl}/api/auth/refresh',
            data: {'refreshToken': refreshToken},
          )
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        logger.e('Forbidden to refresh token: ${response.statusCode}');
        _logout?.call();
        return null;
      }

      if (response.statusCode == 200) {
        final token = response.data['accessToken'];
        print('refreshToken POST save to cache');
        _cache = token;
        return token;
      } else {
        throw Exception('Failed to refreshToken: ${response.statusCode}, $response');
      }
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      return null;
    }
  });
}
