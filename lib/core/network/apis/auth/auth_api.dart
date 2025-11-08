import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'login_dtos.dart';
import 'logout_dtos.dart';
import 'refresh_dtos.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, String baseUrl) => _AuthApi(
    dio,
    baseUrl: '$baseUrl/api/auth'
  );

  @POST('/login')
  @Headers(<String, dynamic>{
    "requiresToken": false
  })
  Future<LoginResponseDto> login({@Body() required LoginRequestDto data});

  @Headers(<String, dynamic>{
    "requiresToken": false
  })
  @POST('/refresh')
  Future<RefreshResponseDto> refresh({@Body() required RefreshRequestDto data});

  @Headers(<String, dynamic>{
    "requiresToken": false
  })
  @POST('/logout')
  Future<void> logout({@Body() required LogoutRequestDto data});
}
