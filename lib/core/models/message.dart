import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';

part 'message.freezed.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    required int id,
    required User user,
    required String message,
    required int chatId,
    required bool isRead,
    required int createdAt,
    required int? editedAt,
  }) = _Message;

  factory Message.loading() =>
      Message(id: -3,
          user: User.loading(),
          message: '---------------------------',
          chatId: -1,
          isRead: true,
          createdAt: 0,
          editedAt: 0);

  factory Message.fromDto(MessageDto dto) =>
      Message(
        user: dto.user != null
            ? User.fromDto(dto.user!)
            : User(
          id: dto.isCurrentUser! ? (dto.otherUserId ?? dto.senderId) : dto.senderId,
          username: '',
          profileImage: '',
          /// need only this field
          isCurrent: dto.isCurrentUser!,
        ),
        id: dto.id,
        message: dto.message,
        chatId: dto.chatId,
        isRead: dto.isRead,
        createdAt: dto.createdAt,
        editedAt: dto.editedAt,
      );

  /// ui line
  factory Message.unreadMessages() =>
      Message(
        id: -2,
        user: User.loading(),
        message: '',
        chatId: -1,
        /// should be true so counter of unread messages works properly
        isRead: true,
        createdAt: 0,
        editedAt: null,
      );
}
