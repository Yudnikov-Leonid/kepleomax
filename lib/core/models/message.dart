import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';

part 'message.freezed.dart';

@freezed
abstract class Message with _$Message {

  const factory Message({
    required int id,
    required int chatId,
    required int senderId,
    required bool isCurrentUser,
    required String message,
    required bool fromCache,
    required bool isRead,
    required DateTime createdAt,
    required DateTime? editedAt,
  }) = _Message;

  factory Message.loading() => Message(
    id: -3,
    senderId: -1,
    isCurrentUser: false,
    fromCache: false,
    message: '---------------------------',
    chatId: -1,
    isRead: true,
    createdAt: DateTime(10000),
    editedAt: null,
  );

  factory Message.fromDto(MessageDto dto) => Message(
    id: dto.id,
    chatId: dto.chatId,
    senderId: dto.senderId,
    isCurrentUser: dto.isCurrentUser,
    message: dto.message,
    fromCache: dto.fromCache,
    isRead: dto.isRead,
    createdAt: DateTime.fromMillisecondsSinceEpoch(dto.createdAt),
    editedAt: dto.editedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(dto.editedAt!),
  );

  /// TODO make it better
  /// used to display line in the ui
  factory Message.unreadMessages() => Message(
    id: unreadMessagesId,
    senderId: -1,
    fromCache: false,
    // TODO true or false to work properly?
    isCurrentUser: false,
    message: '',
    chatId: -1,
    // should be true so counter of unread messages works properly
    isRead: true,
    createdAt: DateTime(10000),
    editedAt: null,
  );

  factory Message.date(DateTime dateTime) => Message(
    id: dateId,
    senderId: -1,
    fromCache: false,
    isCurrentUser: false,
    message: '',
    chatId: -1,
    // should be true so counter of unread messages works properly
    isRead: true,
    createdAt: dateTime,
    editedAt: null,
  );
  const Message._();

  static const unreadMessagesId = -2;
  static const dateId = -3;

  bool get isSystem => id == unreadMessagesId || id == dateId;

  MessageDto toDto() => MessageDto(
    id: id,
    chatId: chatId,
    senderId: senderId,
    isCurrentUser: isCurrentUser,
    //user: user.toDto(),
    //otherUserId: null,
    message: message,
    isRead: isRead,
    createdAt: createdAt.millisecondsSinceEpoch,
    editedAt: editedAt?.millisecondsSinceEpoch,
    fromCache: fromCache,
  );
}
