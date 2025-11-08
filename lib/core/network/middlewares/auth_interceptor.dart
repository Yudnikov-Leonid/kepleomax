import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:kepleomax/main.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final TokenProvider _tokenProvider;
  final AuthController _authController;

  AuthInterceptor({
    required TokenProvider tokenProvider,
    required AuthController authController,
  }): _authController = authController, _tokenProvider = tokenProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers["requiresToken"] == false) {
      options.headers.remove("requiresToken");
      return handler.next(options);
    }

    var accessToken = _tokenProvider.getAccessToken();
    final refreshToken = await _tokenProvider.getRefreshToken();
    if (accessToken == null || refreshToken == null || accessToken.isEmpty || refreshToken.isEmpty) {
      handler.reject(
        DioException(requestOptions: options, message: 'No token', type: DioExceptionType.cancel),
      );
    }

    final accessTokenHasExpired = JwtDecoder.isExpired(accessToken!);
    final refreshTokenHasExpired = JwtDecoder.isExpired(refreshToken!);

    if (refreshTokenHasExpired) {
      _logout();
      return handler.reject(
          DioException(requestOptions: options, message: 'Refresh token is expired', type: DioExceptionType.cancel)
      );
    } else if (accessTokenHasExpired) {
      final newAccessToken = await _refreshToken(refreshToken);
      if (newAccessToken == null) {
        _logout();
        return handler.reject(
            DioException(requestOptions: options, message: 'Refresh token is expired', type: DioExceptionType.cancel)
        );
      } else {
        await _tokenProvider.saveAccessToken(newAccessToken);
        accessToken = newAccessToken;
      }
    }

    handler.next(options..headers.addAll({'Authorization': 'Bearer $accessToken'}));
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
        _logout();
    }
    handler.next(err);
  }

  Future<void> _logout() async {
    await _authController.logout(); // TODO
    await _tokenProvider.clearAll();
  }

  Future<String?> _refreshToken(String refreshToken) async {
    try {
      final dio = Dio(); // because current dio is locked

      final response = await dio.post(
          '${flavor.baseUrl}/api/user/refresh',
          data: {'refreshToken': refreshToken}
      );

      if (response.statusCode == 200) {
        return response.data['accessToken'];
      } else {
        _logout();
      }

    } catch (e) {
      return null;
    }
    return null;
  }
}
