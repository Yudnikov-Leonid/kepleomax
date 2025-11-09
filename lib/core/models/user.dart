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
  }) = _User;

  factory User.fromDto(UserDto dto) =>
      User(id: dto.id, email: dto.email, username: dto.username);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
