import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  final int id;
  final String email;
  final String username;
  @JsonKey(name: 'profile_image')
  final String profileImage;

  UserDto({
    required this.id,
    required this.email,
    required this.username,
    required this.profileImage,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
