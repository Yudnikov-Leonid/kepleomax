import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

part 'profile_dtos.g.dart';

@JsonSerializable()
class GetProfileResponseDto {
  final GetProfileDataDto? data;
  final String? message;

  GetProfileResponseDto({required this.data, required this.message});

  factory GetProfileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GetProfileResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetProfileResponseDtoToJson(this);
}

@JsonSerializable()
class EditProfileRequestDto {
  final String username;
  final String description;

  EditProfileRequestDto({required this.username, required this.description});

  factory EditProfileRequestDto.fromJson(Map<String, dynamic> json) =>
      _$EditProfileRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EditProfileRequestDtoToJson(this);
}

@JsonSerializable()
class GetProfileDataDto {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String description;
  final UserDto user;

  GetProfileDataDto({
    required this.id,
    required this.userId,
    required this.description,
    required this.user,
  });

  factory GetProfileDataDto.fromJson(Map<String, dynamic> json) =>
      _$GetProfileDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetProfileDataDtoToJson(this);
}