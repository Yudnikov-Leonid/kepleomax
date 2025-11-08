import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_dtos.g.dart';

@JsonSerializable()
class LoginRequestDto {
  final String email;
  final String password;

  LoginRequestDto({required this.email, required this.password});

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}

@JsonSerializable()
class LoginResponseDto {
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user; // TODO

  LoginResponseDto({required this.accessToken, required this.refreshToken, required this.user});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);
}