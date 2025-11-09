import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

part 'get_user_dto.g.dart';

@JsonSerializable()
class GetUserDto {
  final UserDto? data;
  final String? message;

  GetUserDto({required this.data, required this.message});

  factory GetUserDto.fromJson(Map<String, dynamic> json) => _$GetUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetUserDtoToJson(this);
}