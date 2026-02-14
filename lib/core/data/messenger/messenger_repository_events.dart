// import 'dart:async';
//
// import 'package:collection/collection.dart';
// import 'package:kepleomax/core/data/data_sources/chats_api_data_sources.dart';
// import 'package:kepleomax/core/data/local_data_sources/chats_local_data_source.dart';
// import 'package:kepleomax/core/data/local_data_sources/messages_local_data_source.dart';
// import 'package:kepleomax/core/data/models/chats_collection.dart';
// import 'package:kepleomax/core/data/models/messages_collection.dart';
// import 'package:kepleomax/core/models/chat.dart';
// import 'package:kepleomax/core/models/message.dart';
// import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
// import 'package:kepleomax/core/network/websockets/models/deleted_message_update.dart';
// import 'package:kepleomax/core/network/websockets/models/read_messages_update.dart';
//
// abstract class MessengerRepositoryEvents {
//   /// events
//   void onNewMessage(MessageDto messageDto);
//
//   void onReadMessages(ReadMessagesUpdate update);
//
//   void onDeletedMessage(DeletedMessageUpdate update);
//
//   /// emitters
//   void emitMessagesCollection(MessagesCollection collection);
//
//   void emitMessages(Iterable<Message> messages);
//
//   void emitChatsCollection(ChatsCollection collection);
//
//   /// data streams
//   Stream<MessagesCollection> get messagesUpdatesStream;
//
//   Stream<ChatsCollection> get chatsUpdatesStream;
// }
//
// class MessengerRepositoryEventsImpl implements MessengerRepositoryEvents {
//   final MessagesLocalDataSource _messagesLocal;
//   final ChatsLocalDataSource _chatsLocal;
//   final ChatsApiDataSource _chatsApi;
//
//   final _messagesUpdatesController =
//       StreamController<MessagesCollection>.broadcast();
//   final _chatsUpdatesController = StreamController<ChatsCollection>.broadcast();
//   MessagesCollection? _lastMessagesCollection;
//   ChatsCollection? _lastChatsCollection;
//
//   /// emitters
//   @override
//   void emitMessagesCollection(MessagesCollection collection) {
//     _messagesUpdatesController.add(collection);
//     _lastMessagesCollection = collection;
//   }
//
//   @override
//   void emitMessages(Iterable<Message> messages) {
//     final collection = _lastMessagesCollection!.copyWith(messages: messages);
//     _messagesUpdatesController.add(collection);
//     _lastMessagesCollection = collection;
//   }
//
//   @override
//   void emitChatsCollection(ChatsCollection collection) {
//     _chatsUpdatesController.add(collection);
//     _lastChatsCollection = collection;
//   }
//
//   /// events
//   @override
//   void onNewMessage(MessageDto messageDto) async {
//     _messagesLocal.insert(messageDto);
//
//     if (_lastMessagesCollection != null &&
//         _lastMessagesCollection!.chatId == messageDto.chatId) {
//       final newList = <Message>[
//         Message.fromDto(messageDto),
//         ..._lastMessagesCollection!.messages,
//       ];
//       emitMessages(newList);
//     }
//
//     if (_lastChatsCollection != null) {
//       final newChats = List<Chat>.from(_lastChatsCollection!.chats);
//       final affectedChat = newChats.firstWhereOrNull(
//         (chat) => chat.id == messageDto.chatId,
//       );
//       if (affectedChat != null) {
//         _chatsLocal.increaseUnreadCountBy1(affectedChat.id);
//         newChats.remove(affectedChat);
//         newChats.insert(
//           0,
//           affectedChat.copyWith(
//             lastMessage: Message.fromDto(messageDto),
//             unreadCount:
//                 affectedChat.unreadCount +
//                 (!messageDto.isCurrentUser && !messageDto.isRead ? 1 : 0),
//           ),
//         );
//         emitChatsCollection(ChatsCollection(chats: newChats));
//       } else {
//         /// it's a new chat
//         final newChat = await _chatsApi.getChatWithId(messageDto.chatId);
//         if (newChat == null) return;
//         _chatsLocal.insert(newChat);
//         emitChatsCollection(
//           ChatsCollection(
//             chats: [Chat.fromDto(newChat, fromCache: false), ...newChats],
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   void onReadMessages(ReadMessagesUpdate update) {
//     _messagesLocal.readMessages(update);
//
//     if (_lastMessagesCollection != null &&
//         _lastMessagesCollection!.chatId == update.chatId) {
//       final newList = _lastMessagesCollection!.messages.map(
//         (m) => update.messagesIds.contains(m.id) ? m.copyWith(isRead: true) : m,
//       );
//       emitMessages(newList);
//     }
//
//     if (_lastChatsCollection != null) {
//       if (!update.isCurrentUser) {
//         _chatsLocal.decreaseUnreadCount(update.chatId, update.messagesIds.length);
//         final newList = _lastChatsCollection!.chats.map(
//           (chat) => chat.id == update.chatId
//               ? chat.copyWith(
//                   unreadCount: chat.unreadCount - update.messagesIds.length,
//                 )
//               : chat,
//         );
//         emitChatsCollection(ChatsCollection(chats: newList));
//       } else if (update.messagesIds.contains(
//         _lastChatsCollection!.chats
//             .firstWhereOrNull((c) => c.id == update.chatId)
//             ?.lastMessage
//             ?.id,
//       )) {
//         final newList = _lastChatsCollection!.chats.map(
//           (chat) => chat.id == update.chatId
//               ? chat.copyWith(lastMessage: chat.lastMessage!.copyWith(isRead: true))
//               : chat,
//         );
//         emitChatsCollection(ChatsCollection(chats: newList));
//       }
//     }
//   }
//
//   @override
//   void onDeletedMessage(DeletedMessageUpdate update) {
//     _messagesLocal.deleteById(update.deletedMessage.id);
//
//     if (_lastMessagesCollection != null &&
//         _lastMessagesCollection!.chatId == update.chatId) {
//       final newList = _lastMessagesCollection!.messages.where(
//         (m) => m.id != update.deletedMessage.id,
//       );
//       emitMessages(newList);
//     }
//
//     if (_lastChatsCollection != null) {
//       final newChats = List<Chat>.from(_lastChatsCollection!.chats);
//       final affectedChatIndex = newChats.indexWhere(
//         (chat) => chat.id == update.chatId,
//       );
//       if (affectedChatIndex != -1) {
//         final decreaseUnreadCount =
//             !update.deletedMessage.isCurrentUser && !update.deletedMessage.isRead;
//         final newUnreadCount =
//             newChats[affectedChatIndex].unreadCount - (decreaseUnreadCount ? 1 : 0);
//         if (update.newLastMessage != null) {
//           newChats[affectedChatIndex] = newChats[affectedChatIndex].copyWith(
//             lastMessage: Message.fromDto(update.newLastMessage!),
//             unreadCount: newUnreadCount,
//           );
//         } else {
//           newChats[affectedChatIndex] = newChats[affectedChatIndex].copyWith(
//             unreadCount: newUnreadCount,
//           );
//         }
//         newChats.sort(
//           (a, b) =>
//               (b.lastMessage?.createdAt.millisecondsSinceEpoch ?? 0) -
//               (a.lastMessage?.createdAt.millisecondsSinceEpoch ?? 0),
//         );
//         emitChatsCollection(ChatsCollection(chats: newChats));
//       }
//     }
//   }
//
//   @override
//   Stream<ChatsCollection> get chatsUpdatesStream => _chatsUpdatesController.stream;
//
//   @override
//   Stream<MessagesCollection> get messagesUpdatesStream => _messagesUpdatesController.stream;
// }
