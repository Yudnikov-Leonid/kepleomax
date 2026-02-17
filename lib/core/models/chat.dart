import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';

part 'chat.freezed.dart';

@freezed
abstract class Chat with _$Chat {
  const Chat._();

  const factory Chat({
    required int id,
    required User otherUser,
    required Message? lastMessage,
    required bool fromCache,
    required int unreadCount,
    DateTime? lastTypingActivityTime,
  }) = _Chat;

  bool get isTypingRightNow => lastTypingActivityTime == null
      ? false
      : lastTypingActivityTime!.millisecondsSinceEpoch +
                AppConstants.showTypingAfterActivityForSeconds * 1000 >
            DateTime.now().millisecondsSinceEpoch;

  factory Chat.fromDto(ChatDto dto, {required fromCache}) => Chat(
    id: dto.id,
    otherUser: User.fromDto(dto.otherUser),
    lastMessage: dto.lastMessage == null ? null : Message.fromDto(dto.lastMessage!),
    fromCache: fromCache,
    unreadCount: dto.unreadCount,
  );

  ChatDto toDto() => ChatDto(
    id: id,
    otherUser: otherUser.toDto(),
    lastMessage: lastMessage?.toDto(),
    unreadCount: unreadCount,
  );

  factory Chat.loading() => Chat(
    id: -1,
    otherUser: User.loading(),
    fromCache: false,
    lastMessage: null,
    unreadCount: 1,
  );
}
