import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_dtos.g.dart';

@JsonSerializable()
class RefreshRequestDto {
  final String refreshToken;

  RefreshRequestDto({required this.refreshToken});

  factory RefreshRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshRequestDtoToJson(this);
}

@JsonSerializable()
class RefreshResponseDto {
  final String accessToken;

  RefreshResponseDto({required this.accessToken});

  factory RefreshResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshResponseDtoToJson(this);
}