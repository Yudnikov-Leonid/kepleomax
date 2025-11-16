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

  factory Message.fromDto(MessageDto dto) => Message(
    user: User(
      id: dto.senderId,
      email: '',
      username: '',
      profileImage: '',
      isCurrent: dto.isCurrentUser,
    ),
    id: dto.id,
    message: dto.message,
    chatId: dto.chatId,
    isRead: dto.isRead,
    createdAt: int.parse(dto.createdAt),
    editedAt: dto.editedAt == null ? null : int.parse(dto.editedAt!),
  );
}
