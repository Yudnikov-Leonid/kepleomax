import 'dart:async';
import 'dart:io';

import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/data/local_data_sources/users_local_data_source.dart';
import 'package:kepleomax/core/data/models/users_collection.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/core/network/apis/files/files_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_api.dart';
import 'package:kepleomax/core/network/apis/profile/profile_dtos.dart';
import 'package:kepleomax/core/network/apis/user/get_user_dtos.dart';
import 'package:kepleomax/core/network/apis/user/user_api.dart';

abstract class UserRepository {
  Future<User> getUser({required int userId});

  Future<UserProfile> getUserProfile(int userId);

  Future<UserProfile> updateProfile(UserProfile profile, {bool updateImage = false});

  /// search
  Stream<UsersCollection> get usersStream;

  Future<void> loadSearch({required String search});

  Future<void> loadMore();

  Future<bool> addFCMToken({required String token});

  Future<void> deleteFCMToken({required String token});

  /// cache currentUser
  User? getCurrentUserFromCache();

  Future<void> setCurrentUser(User? user);
}

class UserRepositoryImpl implements UserRepository {

  UserRepositoryImpl({
    required ProfileApi profileApi,
    required FilesApi filesApi,
    required UserApi userApi,
    required UsersLocalDataSource usersLocalDataSource,
  }) : _userApi = userApi,
       _profileApi = profileApi,
       _filesApi = filesApi,
       _usersLocalDataSource = usersLocalDataSource;
  final UserApi _userApi;
  final ProfileApi _profileApi;
  final FilesApi _filesApi;
  final UsersLocalDataSource _usersLocalDataSource;
  final _usersController = StreamController<UsersCollection>.broadcast();
  UsersCollection _lastUsersCollection = const UsersCollection(users: []);
  String _cachedSearch = '';

  void _emitUsersCollection(UsersCollection collection) {
    _lastUsersCollection = collection;
    _usersController.add(collection);
  }

  @override
  Future<User> getUser({required int userId}) async {
    final res = await _userApi.getUser(userId: userId);

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? 'Failed to get user: ${res.response.statusCode}',
      );
    }

    final dto = res.data.data!;
    unawaited(_usersLocalDataSource.insert(dto));
    return User.fromDto(dto);
  }

  @override
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

  @override
  Future<UserProfile> updateProfile(
    UserProfile profile, {
    bool updateImage = false,
  }) async {
    String? newImagePath;
    if (!updateImage) {
      newImagePath = null;
    } else {
      /// set newImagePath
      if (profile.user.profileImage == null || profile.user.profileImage!.isEmpty) {
        newImagePath = null;
      } else {
        final imageRes = await _filesApi.uploadFile(
          File(profile.user.profileImage!),
        );

        if (imageRes.response.statusCode != 201) {
          throw Exception(
            imageRes.data.message ??
                'Failed to upload image: ${imageRes.response.statusCode}',
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
        res.data.message ?? 'Failed to update profile: ${res.response.statusCode}',
      );
    }

    return profile.copyWith(
      user: profile.user.copyWith(
        profileImage: newImagePath ?? profile.user.profileImage,
      ),
    );
  }

  @override
  Future<void> loadSearch({
    required String search
  }) async {
    _cachedSearch = search;
    /// don't need search.trim()
    final res = await _userApi.searchUsers(
      search: search,
      limit: AppConstants.peoplePagingLimit,
      cursor: null,
    );

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? 'Failed to get users: ${res.response.statusCode}',
      );
    }

    final dtos = res.data.data;
    unawaited(_usersLocalDataSource.insertAll(dtos));
    _emitUsersCollection(
      UsersCollection(
        users: dtos.map(User.fromDto),
        allUsersLoaded: dtos.length < AppConstants.peoplePagingLimit,
      ),
    );
  }

  @override
  Future<void> loadMore() async {
    final res = await _userApi.searchUsers(
      search: _cachedSearch,
      limit: AppConstants.peoplePagingLimit,
      cursor: _lastUsersCollection.users.last.id,
    );

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? 'Failed to get users: ${res.response.statusCode}',
      );
    }

    final dtos = res.data.data;
    unawaited(_usersLocalDataSource.insertAll(dtos));
    _emitUsersCollection(
      UsersCollection(
        users: [..._lastUsersCollection.users, ...dtos.map(User.fromDto)],
        allUsersLoaded: dtos.length < AppConstants.peoplePagingLimit,
      ),
    );
  }

  @override
  Future<bool> addFCMToken({required String token}) async {
    final result = await _userApi.addFCMToken(body: FCMTokenRequest(token: token));
    return result.response.statusCode == 200;
  }

  @override
  Future<void> deleteFCMToken({required String token}) async {
    await _userApi.deleteFCMToken(body: FCMTokenRequest(token: token));
  }

  @override
  User? getCurrentUserFromCache() => _usersLocalDataSource.getCurrentUser();

  @override
  Future<void> setCurrentUser(User? user) =>
      _usersLocalDataSource.setCurrentUser(user);

  @override
  Stream<UsersCollection> get usersStream => _usersController.stream;
}
