import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/flavor/flavor.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';
import 'package:kepleomax/main.dart';
import 'package:retrofit/dio.dart';

import '../../mocks/fake_chats_api.dart';
import '../../mocks/fake_local_chats_database.dart';
import '../../mocks/fake_messages_web_socket.dart';

/// flutter test test/features/chats/chats_repository_test.dart

void main() {
  group('chats_repository_test', () {
    late ChatsRepository chatsRepository;
    late FakeChatsApi fakeChatsApi;
    late FakeLocalChatsDatabase fakeLocalChatsDatabase;
    late FakeMessagesWebSocket fakeMessagesRepository;
    late StreamIterator<List<Chat>> streamIterator;

    setUp(() {
      /// init env
      flavor = Flavor.release();

      /// init repository
      fakeChatsApi = FakeChatsApi();
      fakeLocalChatsDatabase = FakeLocalChatsDatabase();
      fakeMessagesRepository = FakeMessagesWebSocket();
      chatsRepository = ChatsRepository(
        chatsApi: fakeChatsApi,
        localChatsDatabase: fakeLocalChatsDatabase,
        webSocket: fakeMessagesRepository,
      );
      streamIterator = StreamIterator(chatsRepository.chatsUpdatesStream);
    });

    /// should get api call, if result is success then save it to the localStorage
    /// and return the list of chats
    test('getChats()', () async {
      /// success
      final responseData = <ChatDto>[_chatDto1];
      fakeChatsApi.getChatsMustReturn(
        HttpResponse(
          ChatsResponse(data: responseData, message: null),
          Response(requestOptions: RequestOptions(), statusCode: 200),
        ),
      );
      var actual = await chatsRepository.getChats();
      var expected = [Chat.fromDto(_chatDto1)];
      expect(actual, expected);
      fakeLocalChatsDatabase.checkClearAndInsertChatsCalledTimes(1);
      fakeLocalChatsDatabase.checkClearAndInsertChatsCalledWith(responseData);

      /// fail with message from the response
      fakeChatsApi.getChatsMustReturn(
        HttpResponse(
          ChatsResponse(data: null, message: 'error message'),
          Response(requestOptions: RequestOptions(), statusCode: 400),
        ),
      );
      expect(
        () async => await chatsRepository.getChats(),
        throwsA(
          predicate(
            (e) => e is Exception && e.toString() == 'Exception: error message',
          ),
        ),
      );

      /// fail without message
      fakeChatsApi.getChatsMustReturn(
        HttpResponse(
          ChatsResponse(data: null, message: null),
          Response(requestOptions: RequestOptions(), statusCode: 400),
        ),
      );
      expect(
        () async => await chatsRepository.getChats(),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString() == 'Exception: Failed to get chats, statusCode: 400',
          ),
        ),
      );
    });

    test('getChatsFromCache()', () async {
      final list = [_chatDto1];
      fakeLocalChatsDatabase.getChatsMustReturn(list);
      final actual = await chatsRepository.getChatsFromCache();
      expect(actual, list.map(Chat.fromDto).toList());
    });

    //test('newMessage', () async {
    /// message to the upper chat
    // fakeLocalChatsDatabase.getChatsMustReturn([_chatDto1, _chatDto2]);
    // fakeMessagesRepository.addNewMessage(_message1);
    // await streamIterator.moveNext();
    // // check
    // final chat1New = Chat(
    //   id: _chatDto1.id,
    //   otherUser: Chat.fromDto(_chatDto1).otherUser,
    //   lastMessage: _message1,
    //   unreadCount: _chatDto1.unreadCount + 1,
    // );
    // List<Chat> actual = streamIterator.current;
    // List<Chat> expected = [chat1New, Chat.fromDto(_chatDto2)];
    // expect(actual, expected);
    //
    // /// message to the lower chat
    // fakeLocalChatsDatabase.getChatsMustReturn(
    //   expected.map((e) => e.toDto()).toList(),
    // );
    // fakeMessagesRepository.addNewMessage(_message2);
    // await streamIterator.moveNext();
    // // check
    // final chat2New = Chat(
    //   id: 1,
    //   otherUser: Chat.fromDto(_chatDto2).otherUser,
    //   lastMessage: _message2,
    //   unreadCount: _chatDto2.unreadCount + 1,
    // );
    // actual = streamIterator.current;
    // expected = [chat2New, chat1New];
    // expect(actual, expected);
    //
    // /// message to the upper chat
    // fakeLocalChatsDatabase.getChatsMustReturn(
    //   expected.map((e) => e.toDto()).toList(),
    // );
    // fakeMessagesRepository.addNewMessage(_message1);
    // await streamIterator.moveNext();
    // // check
    // final chatDto2NewNew = Chat(
    //   id: chat2New.id,
    //   otherUser: chat2New.otherUser,
    //   lastMessage: _message3,
    //   unreadCount: chat2New.unreadCount + 1,
    // );
    // actual = streamIterator.current;
    // expected = [chatDto2NewNew, chat1New];
    // expect(actual, expected);
    //});

    //test('readMessage', () async {
    // /// read 1 not the last message
    // fakeLocalChatsDatabase.getChatsMustReturn([
    //   ChatDto(
    //     id: _chatDto1.id,
    //     otherUser: _chatDto1.otherUser,
    //     lastMessage: _chatDto1.lastMessage,
    //     unreadCount: 10, // not just _chatDto1 so change this
    //   ),
    //   _chatDto2,
    // ]);
    // fakeMessagesRepository.addReadMessages(
    //   ReadMessagesUpdate(chatId: 0, senderId: 1, messagesIds: [4]),
    // );
    // await streamIterator.moveNext();
    // // check
    // List<Chat> actual = streamIterator.current;
    // Chat expectedChat = Chat(
    //   id: _chatDto1.id,
    //   otherUser: User.fromDto(_chatDto1.otherUser),
    //   lastMessage: Message.fromDto(_chatDto1.lastMessage!),
    //   unreadCount: 9,
    // );
    // List<Chat> expected = [expectedChat, Chat.fromDto(_chatDto2)];
    // expect(actual, expected);
    //
    // /// read 3 not the last messages
    // fakeLocalChatsDatabase.getChatsMustReturn([expectedChat.toDto(), _chatDto2]);
    // fakeMessagesRepository.addReadMessages(
    //   ReadMessagesUpdate(chatId: 0, senderId: 1, messagesIds: [5,6,7]),
    // );
    // await streamIterator.moveNext();
    // // check
    // actual = streamIterator.current;
    // expectedChat = expectedChat.copyWith(unreadCount: expectedChat.unreadCount - 3);
    // expected = [expectedChat, Chat.fromDto(_chatDto2)];
    // expect(actual, expected);
    //
    // /// read the last message
    //});
  });
}

const _chatDto1 = ChatDto(
  id: 0,
  otherUser: UserDto(
    id: 1,
    username: 'username',
    profileImage: null,
    isCurrent: false,
  ),
  lastMessage: MessageDto(
    id: 2,
    chatId: 0,
    senderId: 1,
    isCurrentUser: false,
    user: null,
    otherUserId: 1,
    message: 'message',
    isRead: false,
    createdAt: 0,
    editedAt: null,
  ),
  unreadCount: 1,
);

const _chatDto2 = ChatDto(
  id: 1,
  otherUser: UserDto(
    id: 2,
    username: 'username',
    profileImage: null,
    isCurrent: false,
  ),
  lastMessage: MessageDto(
    id: 3,
    chatId: 1,
    senderId: 2,
    isCurrentUser: false,
    user: null,
    otherUserId: 2,
    message: 'message2',
    isRead: false,
    createdAt: 0,
    editedAt: null,
  ),
  unreadCount: 2,
);

const _message1 = Message(
  id: 4,
  user: User(id: 5, username: 'cool username', profileImage: null, isCurrent: false),
  message: 'new message',
  chatId: 0,
  isRead: false,
  createdAt: 0,
  editedAt: null,
);

const _message2 = Message(
  id: 4,
  user: User(
    id: 6,
    username: 'cool username2',
    profileImage: null,
    isCurrent: false,
  ),
  message: 'new message2',
  chatId: 1,
  isRead: false,
  createdAt: 0,
  editedAt: null,
);

const _message3 = Message(
  id: 4,
  user: User(id: 5, username: 'cool username', profileImage: null, isCurrent: false),
  message: 'new message3',
  chatId: 0,
  isRead: false,
  createdAt: 0,
  editedAt: null,
);
