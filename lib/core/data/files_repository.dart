import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kepleomax/core/network/apis/files/files_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';
import 'package:kepleomax/core/presentation/map_exceptions.dart';

import '../../main.dart';

abstract class IFilesRepository {
  Future<String> uploadFile(String path);
}

class FilesRepository implements IFilesRepository {
  final FilesApi _filesApi;

  FilesRepository({required FilesApi filesApi}) : _filesApi = filesApi;

  @override
  Future<String> uploadFile(String path) async {
    try {
      final res = await _filesApi
          .uploadFile(File(path))
          .timeout(ApiConstants.longTimeout);

      if (res.response.statusCode != 201) {
        throw Exception(
          res.data.message ?? "Failed to upload image: ${res.response.statusCode}",
        );
      }

      return res.data.data!.path;
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }
}
