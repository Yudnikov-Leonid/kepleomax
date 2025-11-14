import 'dart:io';

import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/core/network/apis/files/files_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_dtos.dart';
import 'package:kepleomax/core/network/apis/user/user_api.dart';

class UserRepository {
  final UserApi _userApi;
  final ProfileApi _profileApi;
  final FilesApi _filesApi;

  UserRepository({
    required ProfileApi profileApi,
    required FilesApi filesApi,
    required UserApi userApi,
  }) : _userApi = userApi,
       _profileApi = profileApi,
       _filesApi = filesApi;

  Future<List<User>> search({required String search, required int limit, required int offset}) async {
    final res = await _userApi.searchUsers(search: search, limit: limit, offset: offset);

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ??
            "Failed to get users: ${res.response.statusCode}",
      );
    }

    return res.data.data.map(User.fromDto).toList();
  }

  Future<UserProfile> getUserProfile(int userId) async {
    final res = await _profileApi.getProfile(userId.toString());

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ??
            "Failed to get user's profile: ${res.response.statusCode}",
      );
    }

    return UserProfile(
      user: User.fromDto(res.data.data!.user),
      description: res.data.data!.description,
    );
  }

  Future<UserProfile> updateProfile(
    UserProfile profile, {
    updateImage = false,
  }) async {
    String? newImagePath;
    if (updateImage && profile.user.profileImage.isEmpty) {
      newImagePath = '';
    } else if (updateImage) {
      final imageRes = await _filesApi.uploadFile(File(profile.user.profileImage));

      if (imageRes.response.statusCode != 201) {
        throw Exception(
          imageRes.data.message ??
              "Failed to upload image: ${imageRes.response.statusCode}",
        );
      }

      newImagePath = imageRes.data.data!.path;
    }

    final res = await _profileApi.editProfile(
      EditProfileRequestDto(
        username: profile.user.username.trim(),
        description: profile.description.trim(),
        profileImage: newImagePath ?? profile.user.profileImage,
      ),
    );

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to update profile: ${res.response.statusCode}",
      );
    }

    return profile.copyWith(
      user: profile.user.copyWith(
        profileImage: newImagePath ?? profile.user.profileImage,
      ),
    );
  }
}
