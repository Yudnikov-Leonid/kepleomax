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
  final LoginResponseData? data;
  final String? message;

  LoginResponseDto({this.data, this.message});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);
}

@JsonSerializable()
class LoginResponseData {
  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user; // TODO

  LoginResponseData({required this.accessToken, required this.refreshToken, required this.user});

  factory LoginResponseData.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDataToJson(this);
}