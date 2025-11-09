import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'profile_dtos.dart';

part 'profile_api.g.dart';

@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio, String baseUrl) =>
      _ProfileApi(dio, baseUrl: '$baseUrl/api/profile');

  @GET('/')
  Future<HttpResponse<GetProfileResponseDto>> getProfile(
    @Query("userId") String userId,
  );

  @POST('/')
  Future<HttpResponse<GetProfileResponseDto>> editProfile(
    @Body() EditProfileRequestDto body,
  );
}
