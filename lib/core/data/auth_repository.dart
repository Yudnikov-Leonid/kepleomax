import 'package:kepleomax/core/network/apis/auth/auth_api.dart';
import 'package:kepleomax/core/network/apis/auth/login_dtos.dart';
import 'package:kepleomax/core/network/apis/auth/logout_dtos.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';

abstract class IAuthRepository {
  Future<LoginResponseData> login({required String email, required String password});

  Future<void> logout({required String refreshToken});

  Future<void> register({required String email, required String password});
}

class AuthRepository implements IAuthRepository {
  final AuthApi _authApi;

  AuthRepository({required AuthApi authApi}) : _authApi = authApi;

  @override
  Future<LoginResponseData> login({
    required String email,
    required String password,
  }) async {
    final res = await _authApi
        .login(
          data: LoginRequestDto(email: email.trim(), password: password.trim()),
        )
        .timeout(ApiConstants.timeout);

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? 'Failed to logout: ${res.response.statusCode}',
      );
    }

    return res.data.data!;
  }

  @override
  Future<void> logout({required String refreshToken}) => _authApi
      .logout(data: LogoutRequestDto(refreshToken: refreshToken.trim()))
      .timeout(ApiConstants.timeout);

  @override
  Future<void> register({required String email, required String password}) async {
    final res = await _authApi.register(
      data: LoginRequestDto(email: email.trim(), password: password.trim()),
    );

    if (res.response.statusCode != 201 && res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? 'Failed to register a user: ${res.response.statusCode}',
      );
    }
  }
}
