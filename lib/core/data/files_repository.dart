import 'dart:io';

import 'package:kepleomax/core/network/apis/files/files_api.dart';

abstract class FilesRepository {
  Future<String> uploadFile(String path);
}

class FilesRepositoryImpl implements FilesRepository {

  FilesRepositoryImpl({required FilesApi filesApi}) : _filesApi = filesApi;
  final FilesApi _filesApi;

  @override
  Future<String> uploadFile(String path) async {
    final res = await _filesApi
        .uploadFile(File(path.trim()));

    if (res.response.statusCode != 201) {
      throw Exception(
        res.data.message ?? 'Failed to upload image: ${res.response.statusCode}',
      );
    }

    return res.data.data!.path;
  }
}
