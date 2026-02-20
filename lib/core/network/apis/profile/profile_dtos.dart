import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

part 'profile_dtos.g.dart';

@JsonSerializable()
class GetProfileResponseDto {

  GetProfileResponseDto({required this.data, required this.message});

  factory GetProfileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GetProfileResponseDtoFromJson(json);
  final GetProfileDataDto? data;
  final String? message;

  Map<String, dynamic> toJson() => _$GetProfileResponseDtoToJson(this);
}

@JsonSerializable()
class EditProfileRequestDto {

  EditProfileRequestDto({
    required this.username,
    required this.description,
    required this.profileImage,
    required this.updateImage
  });

  factory EditProfileRequestDto.fromJson(Map<String, dynamic> json) =>
      _$EditProfileRequestDtoFromJson(json);
  final String username;
  final String description;
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  @JsonKey(name: 'update_image')
  final bool updateImage;

  Map<String, dynamic> toJson() => _$EditProfileRequestDtoToJson(this);
}

@JsonSerializable()
class GetProfileDataDto {

  GetProfileDataDto({
    required this.id,
    required this.userId,
    required this.description,
    required this.user,
  });

  factory GetProfileDataDto.fromJson(Map<String, dynamic> json) =>
      _$GetProfileDataDtoFromJson(json);
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String description;
  final UserDto user;

  Map<String, dynamic> toJson() => _$GetProfileDataDtoToJson(this);
}
