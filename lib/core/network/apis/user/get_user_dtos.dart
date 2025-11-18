import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

part 'get_user_dtos.g.dart';

@JsonSerializable()
class GetUserDto {
  final UserDto? data;
  final String? message;

  const GetUserDto({required this.data, required this.message});

  factory GetUserDto.fromJson(Map<String, dynamic> json) =>
      _$GetUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetUserDtoToJson(this);
}

@JsonSerializable()
class GetUsersDto {
  final List<UserDto> data;
  final String? message;

  const GetUsersDto({required this.data, required this.message});

  factory GetUsersDto.fromJson(Map<String, dynamic> json) =>
      _$GetUsersDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetUsersDtoToJson(this);
}

@JsonSerializable()
class FCMTokenRequestDto {
  final String token;

  FCMTokenRequestDto({required this.token});

  factory FCMTokenRequestDto.fromJson(Map<String, dynamic> json) =>
      _$FCMTokenRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FCMTokenRequestDtoToJson(this);
}