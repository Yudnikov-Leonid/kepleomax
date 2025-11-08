import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable()
class MessageDto {
  final String? message;

  MessageDto({required this.message});

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}