import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

part 'user.freezed.dart';

part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String username,
    required String profileImage,
    required bool isCurrent,
  }) = _User;

  factory User.fromDto(UserDto dto) => User(
    id: dto.id,
    username: dto.username,
    profileImage: dto.profileImage,
    isCurrent: dto.isCurrent,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.loading() => const User(
    id: -1,
    username: '-------------',
    profileImage: '',
    isCurrent: false,
  );
}
