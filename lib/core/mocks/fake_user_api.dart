import 'package:dio/dio.dart';
import 'package:kepleomax/core/network/apis/user/get_user_dtos.dart';
import 'package:kepleomax/core/network/apis/user/user_api.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';
import 'package:retrofit/dio.dart';

class FakeUserApi implements UserApi {
  @override
  Future<HttpResponse<void>> addFCMToken({required FCMTokenRequest body}) async =>
      HttpResponse(
        null,
        Response(requestOptions: RequestOptions(), statusCode: 200),
      );

  @override
  Future<HttpResponse<void>> deleteFCMToken({required FCMTokenRequest body}) async =>
      HttpResponse(
        null,
        Response(requestOptions: RequestOptions(), statusCode: 200),
      );

  @override
  Future<HttpResponse<GetUserResponse>> getUser({required int userId}) async =>
      HttpResponse(
        GetUserResponse(data: UserDto.testing(), message: null),
        Response(requestOptions: RequestOptions(), statusCode: 200),
      );

  @override
  Future<HttpResponse<GetUsersResponse>> searchUsers({
    required String search,
    required int limit,
    required int offset,
  })  async =>
      HttpResponse(
        const GetUsersResponse(data: [], message: 'No users found'),
        Response(requestOptions: RequestOptions(), statusCode: 200),
      );
}
