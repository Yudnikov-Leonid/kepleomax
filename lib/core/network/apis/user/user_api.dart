import 'package:dio/dio.dart';
import 'package:kepleomax/core/network/apis/user/get_user_dtos.dart';
import 'package:retrofit/retrofit.dart';

part 'user_api.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, String baseUrl) =>
      _UserApi(dio, baseUrl: '$baseUrl/api/user');

  @GET('/')
  Future<HttpResponse<GetUserResponse>> getUser({@Query('userId') required int userId});

  @GET('/search')
  Future<HttpResponse<GetUsersResponse>> searchUsers({
    @Query('search') required String search,
    @Query('limit') required int limit,
    @Query('cursor') required int? cursor,
  });

  @POST('/fcmToken')
  Future<HttpResponse<void>> addFCMToken({
    @Body() required FCMTokenRequest body,
  });

  @DELETE('/fcmToken')
  Future<HttpResponse<void>> deleteFCMToken({
    @Body() required FCMTokenRequest body,
  });
}
