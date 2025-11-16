import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';

part 'chat.freezed.dart';

@freezed
abstract class Chat with _$Chat {
  const factory Chat({
    required int id,
    required User otherUser,
    required Message? lastMessage,
    required int unreadCount,
  }) = _Chat;

  factory Chat.fromDto(ChatDto dto) => Chat(
    id: dto.id,
    otherUser: User.fromDto(dto.otherUser),
    lastMessage: dto.lastMessage == null ? null : Message.fromDto(dto.lastMessage!),
    unreadCount: dto.unreadCount,
  );

  factory Chat.newWithUser(User user) =>
      Chat(id: -1, otherUser: user, lastMessage: null, unreadCount: 0);
}
