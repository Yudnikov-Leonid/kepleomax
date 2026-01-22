import 'dart:convert';

import 'package:equatable/equatable.dart';
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
class ChatDto extends Equatable {
  final int id;
  @JsonKey(name: 'other_user')
  final UserDto otherUser;
  @JsonKey(name: 'last_message')
  final MessageDto? lastMessage;
  @JsonKey(name: 'unread_count')
  final int unreadCount;

  const ChatDto({
    required this.id,
    required this.otherUser,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory ChatDto.fromJson(Map<String, dynamic> json) => _$ChatDtoFromJson(json);

  /// json['other_user'] should be map\<String, dynamic>
  factory ChatDto.fromLocalJson(Map<String, dynamic> json) => ChatDto(
    id: json['id'],
    otherUser: UserDto.fromJson(json['other_user']),
    lastMessage: json['last_message'] == null
        ? null
        : MessageDto.fromJson(jsonDecode(json['last_message']), fromCache: true),
    unreadCount: json['unread_count'],
  );

  Map<String, dynamic> toLocalJson() => {
    'id': id,
    'other_user_id': otherUser.id,
    'unread_count': unreadCount,
  };

  @override
  List<Object?> get props => [id, otherUser, lastMessage, unreadCount];
}
