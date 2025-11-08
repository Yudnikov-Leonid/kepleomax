import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../../common/message_dto.dart';
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

  @POST('/register')
  @Headers(<String, dynamic>{
    "requiresToken": false
  })
  Future<HttpResponse<MessageDto>> register({@Body() required LoginRequestDto data});

  @POST('/login')
  @Headers(<String, dynamic>{
    "requiresToken": false
  })
  Future<HttpResponse<LoginResponseDto>> login({@Body() required LoginRequestDto data});

  @POST('/refresh')
  @Headers(<String, dynamic>{
    "requiresToken": false
  })
  Future<RefreshResponseDto> refresh({@Body() required RefreshRequestDto data});

  @POST('/logout')
  @Headers(<String, dynamic>{
    "requiresToken": false
  })
  Future<void> logout({@Body() required LogoutRequestDto data});
}
