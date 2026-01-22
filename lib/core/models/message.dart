import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';

part 'message.freezed.dart';

@freezed
abstract class Message with _$Message {
  const Message._();

  const factory Message({
    required int id,
    required int chatId,
    required int senderId,
    required bool isCurrentUser,
    required String message,
    required bool fromCache,
    required bool isRead,
    required int createdAt,
    required int? editedAt,
  }) = _Message;

  factory Message.loading() => const Message(
    id: -3,
    senderId: -1,
    isCurrentUser: false,
    fromCache: false,
    message: '---------------------------',
    chatId: -1,
    isRead: true,
    createdAt: 0,
    editedAt: 0,
  );

  factory Message.fromDto(MessageDto dto) => Message(
    id: dto.id,
    chatId: dto.chatId,
    senderId: dto.senderId,
    isCurrentUser: dto.isCurrentUser,
    message: dto.message,
    fromCache: dto.fromCache,
    isRead: dto.isRead,
    createdAt: dto.createdAt,
    editedAt: dto.editedAt,
  );

  MessageDto toDto() => MessageDto(
    id: id,
    chatId: chatId,
    senderId: senderId,
    isCurrentUser: isCurrentUser,
    //user: user.toDto(),
    //otherUserId: null,
    message: message,
    isRead: isRead,
    createdAt: createdAt,
    editedAt: editedAt,
    fromCache: fromCache,
  );

  /// used to display line in the ui
  factory Message.unreadMessages() => const Message(
    id: -2,
    //user: User.loading(),
    senderId: -1,
    fromCache: false,
    // TODO true or false to work properly?
    isCurrentUser: false,
    message: '',
    chatId: -1,

    /// should be true so counter of unread messages works properly
    isRead: true,
    createdAt: 0,
    editedAt: null,
  );
}
