import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';
import 'package:kepleomax/core/network/common/refresh_token.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:kepleomax/main.dart';
import 'package:ntp/ntp.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final TokenProvider _tokenProvider;
  final AuthController _authController;
  final Function() _onRefresh;
  final Dio _refreshTokenDio;

  AuthInterceptor({
    required TokenProvider tokenProvider,
    required AuthController authController,
    required Function() onRefresh,
    required Dio refreshTokenDio,
  }) : _refreshTokenDio = refreshTokenDio,
       _authController = authController,
       _tokenProvider = tokenProvider,
       _onRefresh = onRefresh;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.headers["requiresToken"] == false) {
      options.headers.remove("requiresToken");
      return handler.next(options);
    }

    var accessToken = _tokenProvider.getAccessToken();
    final refreshToken = await _tokenProvider.getRefreshToken();
    if (accessToken == null ||
        refreshToken == null ||
        accessToken.isEmpty ||
        refreshToken.isEmpty) {
      logger.e('No token');
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'No token',
          type: DioExceptionType.cancel,
        ),
      );
      return;
    }

    final now = await NTP.now(timeout: ApiConstants.timeout);
    final accessTokenHasExpired = now.isAfter(
      JwtDecoder.getExpirationDate(accessToken),
    );
    final refreshTokenHasExpired = now.isAfter(
      JwtDecoder.getExpirationDate(refreshToken),
    );

    if (refreshTokenHasExpired) {
      logger.i('refresh token has expired');
      _logout();
      return handler.reject(
        DioException(
          requestOptions: options,
          message: 'Refresh token is expired',
          type: DioExceptionType.cancel,
        ),
      );
    } else if (accessTokenHasExpired) {
      final newAccessToken = await RefreshToken(
        dio: _refreshTokenDio,
        logout: _logout,
      ).refreshToken(refreshToken);
      if (newAccessToken == null) {
        logger.i('access token has expired, failed to refresh');

        /// don't need to logout, cause this error can be if the server is unavailable
        /// or there's no internet connection. We should logout only if request
        /// if success and the status code == 401/403, this logic is made in
        /// _refreshToken() method
        return handler.reject(
          DioException(
            requestOptions: options,
            message: 'Access token is expired',
            type: DioExceptionType.cancel,
          ),
        );
      } else {
        logger.i('access token has expired, success to refresh');
        await _tokenProvider.saveAccessToken(newAccessToken);
        accessToken = newAccessToken;
        _onRefresh();
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
    await _authController.logout();
    await _tokenProvider.clearAll();
  }
}
