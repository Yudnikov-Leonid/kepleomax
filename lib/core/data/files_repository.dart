import 'dart:io';

import 'package:kepleomax/core/network/apis/files/files_api.dart';

class FilesRepository {
  final FilesApi _filesApi;

  FilesRepository({required FilesApi filesApi}) : _filesApi = filesApi;

  Future<String> uploadFile(String path) async {
    final res = await _filesApi.uploadFile(File(path));

    if (res.response.statusCode != 201) {
      throw Exception(res.data.message ?? "Failed to upload image: ${res.response.statusCode}");
    }

    return res.data.data!.path;
  }
}