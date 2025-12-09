import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  final int id;
  final String username;
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  @JsonKey(name: 'is_current')
  final bool isCurrent;

  UserDto({
    required this.id,
    required this.username,
    required this.profileImage,
    required this.isCurrent,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'],
    username: json['username'],
    profileImage: json['profile_image'],
    isCurrent: json['is_current'] == 1
        ? true
        : json['is_current'] == 0
        ? false
        : json['is_current'],
  );

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  Map<String, dynamic> toLocalJson() => {
    'id': id,
    'username': username,
    'profile_image': profileImage,
    'is_current': isCurrent ? 1 : 0,
  };
}
