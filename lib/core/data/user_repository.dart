import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/core/network/apis/files/files_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_dtos.dart';
import 'package:kepleomax/core/network/apis/user/get_user_dtos.dart';
import 'package:kepleomax/core/network/apis/user/user_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';
import 'package:kepleomax/core/presentation/map_exceptions.dart';

import '../../main.dart';

abstract class IUserRepository {
  Future<User> getUser({required int userId});

  Future<List<User>> search({
    required String search,
    required int limit,
    required int offset,
  });

  Future<UserProfile> getUserProfile(int userId);

  Future<UserProfile> updateProfile(UserProfile profile, {updateImage = false});

  Future<void> addFCMToken({required String token});

  Future<void> deleteFCMToken({required String token});
}

class UserRepository implements IUserRepository {
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

  @override
  Future<User> getUser({required int userId}) async {
    try {
      final res = await _userApi
          .getUser(userId: userId)
          .timeout(ApiConstants.timeout);

      if (res.response.statusCode != 200) {
        throw Exception(
          res.data.message ?? 'Failed to get user: ${res.response.statusCode}',
        );
      }

      return User.fromDto(res.data.data!);
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }

  @override
  Future<List<User>> search({
    required String search,
    required int limit,
    required int offset,
  }) async {
    try {
      final res = await _userApi
          .searchUsers(search: search, limit: limit, offset: offset)
          .timeout(ApiConstants.timeout);

      if (res.response.statusCode != 200) {
        throw Exception(
          res.data.message ?? "Failed to get users: ${res.response.statusCode}",
        );
      }

      return res.data.data.map(User.fromDto).toList();
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }

  @override
  Future<UserProfile> getUserProfile(int userId) async {
    try {
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
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }

  @override
  Future<UserProfile> updateProfile(
    UserProfile profile, {
    updateImage = false,
  }) async {
    try {
      String? newImagePath;
      if (updateImage && profile.user.profileImage.isEmpty) {
        newImagePath = '';
      } else if (updateImage) {
        final imageRes = await _filesApi
            .uploadFile(File(profile.user.profileImage))
            .timeout(ApiConstants.timeout);

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
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }

  @override
  Future<void> addFCMToken({required String token}) async {
    try {
      await _userApi.addFCMToken(body: FCMTokenRequestDto(token: token));
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }

  @override
  Future<void> deleteFCMToken({required String token}) async {
    try {
      await _userApi.deleteFCMToken(body: FCMTokenRequestDto(token: token));
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }
}
