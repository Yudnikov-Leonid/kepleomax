import 'package:dio/dio.dart';
import 'package:kepleomax/core/network/apis/auth/auth_api.dart';
import 'package:kepleomax/core/network/apis/auth/login_dtos.dart';
import 'package:kepleomax/core/network/apis/auth/logout_dtos.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';
import 'package:kepleomax/core/presentation/map_exceptions.dart';

import '../../main.dart';

class AuthRepository {
  final AuthApi _authApi;

  AuthRepository({required AuthApi authApi}) : _authApi = authApi;

  Future<LoginResponseData> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _authApi
          .login(
            data: LoginRequestDto(email: email, password: password),
          )
          .timeout(ApiConstants.timeout);

      if (res.response.statusCode != 200) {
        throw Exception(
          res.data.message ?? 'Failed to logout: ${res.response.statusCode}',
        );
      }

      return res.data.data!;
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }

  Future<void> logout({required String refreshToken}) async {
    try {
      await _authApi
          .logout(data: LogoutRequestDto(refreshToken: refreshToken))
          .timeout(ApiConstants.timeout);
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }

  Future<void> register({required String email, required String password}) async {
    try {
      final res = await _authApi.register(data: LoginRequestDto(email: email, password: password));

      if (res.response.statusCode != 201 && res.response.statusCode != 200) {
        throw Exception(
          res.data.message ?? 'Failed to register a user: ${res.response.statusCode}',
        );
      }
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }
}
