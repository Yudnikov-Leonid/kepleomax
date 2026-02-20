import 'package:dio/dio.dart';
import 'package:kepleomax/core/network/apis/profile/profile_dtos.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_api.g.dart';

@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio, String baseUrl) =>
      _ProfileApi(dio, baseUrl: '$baseUrl/api/profile');

  @GET('/')
  Future<HttpResponse<GetProfileResponseDto>> getProfile(
    @Query('userId') String userId,
  );

  @POST('/')
  Future<HttpResponse<GetProfileResponseDto>> editProfile(
    @Body() EditProfileRequestDto body,
  );
}
