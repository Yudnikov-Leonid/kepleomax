// dart format width=200

import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

final chatDto0 = ChatDto(
  id: 0,
  otherUser: UserDto(id: 1, username: 'OTHER_USERNAME_1', profileImage: null, isCurrent: false, isOnline: true, lastActivityTime: DateTime.now().millisecondsSinceEpoch),
  lastMessage: messageDto0,
  unreadCount: 2,
);

final chatDto1 = const ChatDto(
  id: 1,
  otherUser: UserDto(id: 2, username: 'OTHER_USERNAME_2', profileImage: null, isCurrent: false, isOnline: true, lastActivityTime: 0),
  lastMessage: MessageDto(id: 1, chatId: 1, senderId: 2, isCurrentUser: false, message: 'MSG_1', isRead: false, createdAt: 1080, editedAt: null, fromCache: false),
  unreadCount: 4,
);

final chatDto2 = const ChatDto(
  id: 2,
  otherUser: UserDto(id: 3, username: 'OTHER_USERNAME_3', profileImage: null, isCurrent: false, isOnline: false, lastActivityTime: 0),
  lastMessage: MessageDto(id: 2, chatId: 2, senderId: 0, isCurrentUser: true, message: 'MSG_2', isRead: false, createdAt: 1070, editedAt: null, fromCache: false),
  unreadCount: 0,
);

final chatDto3 = const ChatDto(
  id: 3,
  otherUser: UserDto(id: 4, username: 'OTHER_USERNAME_4', profileImage: null, isCurrent: false, isOnline: false, lastActivityTime: 0),
  lastMessage: MessageDto(id: 3, chatId: 3, senderId: 0, isCurrentUser: true, message: 'MSG_3', isRead: true, createdAt: 1060, editedAt: null, fromCache: false),
  unreadCount: 0,
);

final chatDto4 = const ChatDto(
  id: 4,
  otherUser: UserDto(id: 5, username: 'OTHER_USERNAME_5', profileImage: null, isCurrent: false, isOnline: false, lastActivityTime: 0),
  lastMessage: MessageDto(id: 4, chatId: 4, senderId: 5, isCurrentUser: false, message: 'MSG_4', isRead: true, createdAt: 1050, editedAt: null, fromCache: false),
  unreadCount: 0,
);

final messageDto0 = const MessageDto(id: 0, chatId: 0, senderId: 1, isCurrentUser: false, message: 'MSG_0', isRead: false, createdAt: 1090, editedAt: null, fromCache: false);
final messageDto1 = const MessageDto(id: 1, chatId: 0, senderId: 1, isCurrentUser: false, message: 'MSG_1', isRead: false, createdAt: 1080, editedAt: null, fromCache: false);
final messageDto2 = const MessageDto(id: 2, chatId: 0, senderId: 1, isCurrentUser: false, message: 'MSG_2', isRead: true, createdAt: 1070, editedAt: null, fromCache: false);
final messageDto3 = const MessageDto(id: 3, chatId: 0, senderId: 0, isCurrentUser: true, message: 'MSG_3', isRead: false, createdAt: 1060, editedAt: null, fromCache: false);
final messageDto4 = const MessageDto(id: 4, chatId: 0, senderId: 0, isCurrentUser: true, message: 'MSG_4', isRead: true, createdAt: 1050, editedAt: null, fromCache: false);

List<MessageDto> generateMessages(int from, int count, {int chatId = 0}) => List.generate(
  count,
  (i) => MessageDto(id: i + from, chatId: chatId, senderId: 1, isCurrentUser: false, message: 'MSG_${i + from}', isRead: true, createdAt: 800, editedAt: null, fromCache: false),
);
