import 'dart:io';

import 'package:kepleomax/core/data/local_data_sources/users_local_data_source.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/core/network/apis/files/files_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_dtos.dart';
import 'package:kepleomax/core/network/apis/user/get_user_dtos.dart';
import 'package:kepleomax/core/network/apis/user/user_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';

abstract class IUserRepository {
  Future<User> getUser({required int userId});

  Future<UserProfile> getUserProfile(int userId);

  Future<UserProfile> updateProfile(UserProfile profile, {updateImage = false});

  Future<List<User>> search({
    required String search,
    required int limit,
    required int offset,
  });

  Future<bool> addFCMToken({required String token});

  Future<void> deleteFCMToken({required String token});
}

class UserRepository implements IUserRepository {
  final UserApi _userApi;
  final ProfileApi _profileApi;
  final FilesApi _filesApi;
  final IUsersLocalDataSource _usersLocalDataSource;

  UserRepository({
    required ProfileApi profileApi,
    required FilesApi filesApi,
    required UserApi userApi,
    required IUsersLocalDataSource usersLocalDataSource,
  }) : _userApi = userApi,
       _profileApi = profileApi,
       _filesApi = filesApi,
       _usersLocalDataSource = usersLocalDataSource;

  @override
  Future<User> getUser({required int userId}) async {
    final res = await _userApi.getUser(userId: userId).timeout(ApiConstants.timeout);

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? 'Failed to get user: ${res.response.statusCode}',
      );
    }

    final dto = res.data.data!;
    _usersLocalDataSource.insert(dto).ignore();
    return User.fromDto(dto);
  }

  @override
  Future<UserProfile> getUserProfile(int userId) async {
    final res = await _profileApi
        .getProfile(userId.toString())
        .timeout(ApiConstants.timeout);

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

  @override
  Future<UserProfile> updateProfile(
    UserProfile profile, {
    updateImage = false,
  }) async {
    String? newImagePath;
    if (!updateImage) {
      newImagePath = null;
    } else {
      /// set newImagePath
      if (profile.user.profileImage == null || profile.user.profileImage!.isEmpty) {
        newImagePath = null;
      } else {
        final imageRes = await _filesApi
            .uploadFile(File(profile.user.profileImage!))
            .timeout(ApiConstants.timeout);

        if (imageRes.response.statusCode != 201) {
          throw Exception(
            imageRes.data.message ??
                "Failed to upload image: ${imageRes.response.statusCode}",
          );
        }

        newImagePath = imageRes.data.data!.path;
      }
    }

    final res = await _profileApi.editProfile(
      EditProfileRequestDto(
        username: profile.user.username.trim(),
        description: profile.description.trim(),
        profileImage: newImagePath,
        updateImage: updateImage,
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

  @override
  Future<List<User>> search({
    required String search,
    required int limit,
    required int offset,
  }) async {
    /// don't need search.trim()
    final res = await _userApi
        .searchUsers(search: search, limit: limit, offset: offset)
        .timeout(ApiConstants.timeout);

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to get users: ${res.response.statusCode}",
      );
    }

    final dtos = res.data.data;
    _usersLocalDataSource.insertAll(dtos).ignore();
    return dtos.map(User.fromDto).toList();
  }

  @override
  Future<bool> addFCMToken({required String token}) async {
    final result = await _userApi.addFCMToken(
      body: FCMTokenRequestDto(token: token),
    );
    return result.response.statusCode == 200;
  }

  @override
  Future<void> deleteFCMToken({required String token}) async {
    await _userApi.deleteFCMToken(body: FCMTokenRequestDto(token: token));
  }
}
