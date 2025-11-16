import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

part 'chats_dtos.g.dart';

@JsonSerializable()
class ChatResponse {
  final ChatDto? data;
  final String? message;

  ChatResponse({required this.data, required this.message});

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);
}

@JsonSerializable()
class ChatsResponse {
  final List<ChatDto>? data;
  final String? message;

  ChatsResponse({required this.data, required this.message});

  factory ChatsResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatsResponseToJson(this);
}

@JsonSerializable()
class ChatDto {
  final int id;
  @JsonKey(name: 'other_user')
  final UserDto otherUser;
  @JsonKey(name: 'last_message')
  final MessageDto? lastMessage;

  ChatDto({required this.id, required this.otherUser, required this.lastMessage});

  factory ChatDto.fromJson(Map<String, dynamic> json) => _$ChatDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatDtoToJson(this);
}
