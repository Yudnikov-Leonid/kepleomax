import 'package:dio/dio.dart';
import 'package:kepleomax/core/network/apis/user/get_user_dtos.dart';
import 'package:retrofit/retrofit.dart';

part 'user_api.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, String baseUrl) =>
      _UserApi(dio, baseUrl: '$baseUrl/api/user');

  @GET('/')
  Future<HttpResponse<GetUserDto>> getUser({@Query('userId') required int userId});

  @GET('/search')
  Future<HttpResponse<GetUsersDto>> searchUsers({
    @Query('search') required String search,
    @Query('limit') required int limit,
    @Query('offset') required int offset,
  });

  @POST('/fcmToken')
  Future<HttpResponse<GetUserDto>> addFCMToken({
    @Body() required FCMTokenRequestDto body,
  });

  @DELETE('/fcmToken')
  Future<HttpResponse<GetUserDto>> deleteFCMToken({
    @Body() required FCMTokenRequestDto body,
  });
}
