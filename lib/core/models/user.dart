import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

part 'user.freezed.dart';

part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String email,
    required String username,
    required String profileImage,
  }) = _User;

  factory User.fromDto(UserDto dto) => User(
    id: dto.id,
    email: dto.email,
    username: dto.username,
    profileImage: dto.profileImage,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
