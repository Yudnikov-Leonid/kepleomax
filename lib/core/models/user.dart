import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

part 'user.freezed.dart';

part 'user.g.dart';

@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required int id,
    required String username,
    required String? profileImage,
    required bool isCurrent,
    @Default(false) bool isOnline,

    /// TODO change to DateTime
    @Default(0) int lastActivityTime,
  }) = _User;

  /// TODO write what is it
  bool get showOnlineStatus =>
      isOnline &&
      lastActivityTime +
              (AppConstants.markAsOfflineAfterInactivityInSeconds * 1000) >
          DateTime.now().millisecondsSinceEpoch;

  factory User.fromDto(UserDto dto) => User(
    id: dto.id,
    username: dto.username,
    profileImage: dto.profileImage,
    isCurrent: dto.isCurrent,
    isOnline: dto.isOnline,
    lastActivityTime: dto.lastActivityTime,
  );

  UserDto toDto() => UserDto(
    id: id,
    username: username,
    profileImage: profileImage,
    isCurrent: isCurrent,
    isOnline: isOnline,
    lastActivityTime: lastActivityTime,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.loading() => const User(
    id: -1,
    username: '-------------',
    profileImage: null,
    isCurrent: false,
    isOnline: false,
    lastActivityTime: 0,
  );

  factory User.testing() => User.fromDto(UserDto.testing());
}
