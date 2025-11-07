import 'package:freezed_annotation/freezed_annotation.dart';

part 'logout_dtos.g.dart';

@JsonSerializable()
class LogoutRequestDto {
  final String refreshToken;

  LogoutRequestDto({required this.refreshToken});

  factory LogoutRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LogoutRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutRequestDtoToJson(this);
}