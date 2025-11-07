import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'login_dtos.dart';
import 'logout_dtos.dart';
import 'refresh_dtos.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, String baseUrl) => _AuthApi(
    dio,
    baseUrl: '$baseUrl/api/user'
  );

  @POST('/login')
  Future<LoginRequestDto> login({@Body() required LoginResponseDto data});

  @POST('/refresh')
  Future<RefreshRequestDto> refresh({@Body() required RefreshResponseDto data});

  @POST('/logout')
  Future<void> logout({@Body() required LogoutRequestDto data});
}
