import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/core/network/apis/profile/profile_api.dart';

class UserRepository {
  final ProfileApi _profileApi;

  UserRepository({required ProfileApi profileApi}) : _profileApi = profileApi;

  Future<UserProfile> getUserProfile(int userId) async {
    final res = await _profileApi.getProfile(userId.toString());

    if (res.response.statusCode != 200) {
      throw Exception(res.data.message ?? "Failed to get user's profile");
    }

    return UserProfile(
      user: User.fromDto(res.data.data!.user),
      description: res.data.data!.description,
    );
  }
}
