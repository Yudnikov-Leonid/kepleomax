import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kepleomax/core/network/apis/files/files_dtos.dart';
import 'package:retrofit/retrofit.dart';

part 'files_api.g.dart';

@RestApi()
abstract class FilesApi {
  factory FilesApi(Dio dio, String baseUrl) =>
      _FilesApi(dio, baseUrl: '$baseUrl/api/files');

  @POST('/single')
  @MultiPart()
  Future<HttpResponse<UploadFileResponseDto>> uploadFile(
    @Part(name: 'file') File file,
  );
}
