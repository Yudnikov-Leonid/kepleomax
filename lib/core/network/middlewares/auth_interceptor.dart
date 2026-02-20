import 'package:dio/dio.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/logger.dart';
import 'package:kepleomax/core/network/token_provider.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {

  AuthInterceptor({
    required TokenProvider tokenProvider,
    required AuthController authController,
  }) : _authController = authController,
       _tokenProvider = tokenProvider;
  final TokenProvider _tokenProvider;
  final AuthController _authController;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.headers['requiresToken'] == false) {
      options.headers.remove('requiresToken');
      return handler.next(options);
    }

    final accessToken = await _tokenProvider.getAccessToken(
      onLogoutCallback: _logout,
    );
    if (accessToken == null || accessToken.isEmpty) {
      /// logout will be called in _tokenProvider.getAccessToken
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
