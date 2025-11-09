import 'package:dio/dio.dart';
import 'package:kepleomax/core/network/apis/user/get_user_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'user_api.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, String baseUrl) =>
      _UserApi(dio, baseUrl: '$baseUrl/api/user');

  @GET('/')
  Future<HttpResponse<GetUserDto>> getUser({@Query('userId') required int userId});
}