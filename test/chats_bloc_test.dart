import 'dart:async';

import 'package:kepleomax/core/flavor/flavor.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:kepleomax/features/chats/bloc/chats_bloc.dart';
import 'package:kepleomax/features/chats/bloc/chats_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kepleomax/main.dart';
import 'package:logger/logger.dart';

import 'mocks/fake_chats_repository.dart';
import 'mocks/fake_messages_repository.dart';

/// flutter test test/chats_bloc_test.dart

void main() {
  group('chats_bloc_tests', () {
    late FakeChatsRepository chatsRepository;
    late FakeMessagesRepository messagesRepository;
    late ChatsBloc bloc;
    late StreamIterator<ChatsState> statesIterator;

    setUp(() {
      /// init env
      logger = Logger(level: Level.off);
      flavor = Flavor.release();

      chatsRepository = FakeChatsRepository();
      messagesRepository = FakeMessagesRepository();
      bloc = ChatsBloc(
        chatsRepository: chatsRepository,
        messagesRepository: messagesRepository,
        userId: 12,
      );
      statesIterator = StreamIterator(bloc.stream);
    });

    test('load_event', () async {
      ChatsState actual = bloc.state;
      ChatsState expected = ChatsStateBase.initial();
      expect(actual, equals(expected));
      bloc.add(const ChatsEventLoad());

      await statesIterator.moveNext();
      actual = statesIterator.current;
      expected = const ChatsStateBase(
        data: ChatsData(chats: [], totalUnreadCount: 0, isLoading: true),
      );
      expect(actual, equals(expected));

      chatsRepository.getChatsReturn(_chatsList1);

      await statesIterator.moveNext();
      actual = statesIterator.current;
      expected = const ChatsStateBase(
        data: ChatsData(chats: _chatsList1, totalUnreadCount: 5, isLoading: false),
      );
      expect(actual, equals(expected));
    });

    test('load_event_failed', () async {
      bloc.add(const ChatsEventLoad());

      await statesIterator.moveNext();
      chatsRepository.getChatsThrowError();

      await statesIterator.moveNext();
      final actual = statesIterator.current;
      final expected = const ChatsStateError(message: 'Something went wrong');
      expect(actual, equals(expected));
    });

    test('read_message', () async {
      /// load data
      bloc.add(const ChatsEventLoad());
      await statesIterator.moveNext();
      chatsRepository.getChatsReturn(_chatsList1);
      await statesIterator.moveNext();
      ChatsState actual = statesIterator.current;
      ChatsState expected = const ChatsStateBase(
        data: ChatsData(chats: _chatsList1, totalUnreadCount: 5, isLoading: false),
      );
      expect(actual, equals(expected));

      messagesRepository.addNewMessage(_message4);
      await statesIterator.moveNext();
      actual = statesIterator.current;
      expected = ChatsStateBase(
        data: ChatsData(
          chats: [
            Chat(
              id: 0,
              otherUser: _chatsList1[0].otherUser,
              lastMessage: _message4,
              unreadCount: 0,
            ),
            _chatsList1[1],
          ],
          totalUnreadCount:
              5, // totalUnreadCount shouldn't change if read message from current user
          isLoading: false,
        ),
      );
      expect(actual, equals(expected));

      messagesRepository.addReadMessages(
        ReadMessagesUpdate(
          chatId: _message4.chatId,
          senderId: _message4.user.id,
          messagesIds: [_message4.id],
        ),
      );
      await statesIterator.moveNext();
      actual = statesIterator.current;
      expected = ChatsStateBase(
        data: ChatsData(
          chats: [
            Chat(
              id: 0,
              otherUser: _chatsList1[0].otherUser,
              lastMessage: _message4.copyWith(isRead: true),
              unreadCount: 0,
            ),
            _chatsList1[1],
          ],
          totalUnreadCount: 5,
          isLoading: false,
        ),
      );
      expect(actual, equals(expected));
    });

    test('new_message_from_new_chat', () async {
      /// load data
      bloc.add(const ChatsEventLoad());
      await statesIterator.moveNext();
      chatsRepository.getChatsReturn(_chatsList1);
      await statesIterator.moveNext();
      ChatsState actual = statesIterator.current;
      ChatsState expected = const ChatsStateBase(
        data: ChatsData(chats: _chatsList1, totalUnreadCount: 5, isLoading: false),
      );
      expect(actual, equals(expected));

      messagesRepository.addNewMessage(_message3);
      chatsRepository.getChatWithIdReturn(_chat1);

      await statesIterator.moveNext();
      actual = statesIterator.current;
      expected = ChatsStateBase(
        data: ChatsData(
          chats: [
            _chat1.copyWith(id: _message3.chatId),
            ..._chatsList1,
          ],
          totalUnreadCount: 6,
          isLoading: false,
        ),
      );
      expect(actual, equals(expected));
    });

    test('new_message', () async {
      /// load data
      bloc.add(const ChatsEventLoad());
      await statesIterator.moveNext();
      chatsRepository.getChatsReturn(_chatsList1);
      await statesIterator.moveNext();
      ChatsState actual = statesIterator.current;
      ChatsState expected = const ChatsStateBase(
        data: ChatsData(chats: _chatsList1, totalUnreadCount: 5, isLoading: false),
      );
      expect(actual, equals(expected));

      messagesRepository.addNewMessage(_message1);

      await statesIterator.moveNext();
      actual = statesIterator.current;
      expected = ChatsStateBase(
        data: ChatsData(
          chats: [
            Chat(
              id: 0,
              otherUser: _chatsList1[0].otherUser,
              lastMessage: _message1,
              unreadCount: 3,
            ),
            _chatsList1[1],
          ],
          totalUnreadCount: 6,
          isLoading: false,
        ),
      );
      expect(actual, equals(expected));

      messagesRepository.addNewMessage(_message2);
      await statesIterator.moveNext();
      actual = statesIterator.current;
      expected = ChatsStateBase(
        data: ChatsData(
          chats: [
            Chat(
              id: 1,
              otherUser: _chatsList1[1].otherUser,
              lastMessage: _message2,
              unreadCount: 4,
            ),
            Chat(
              id: 0,
              otherUser: _chatsList1[0].otherUser,
              lastMessage: _message1,
              unreadCount: 3,
            ),
          ],
          totalUnreadCount: 7,
          isLoading: false,
        ),
      );
      expect(actual, equals(expected));
    });
  });
}

/// id will be replaced by provided one
const _chat1 = Chat(
  id: -1,
  otherUser: User(
    id: 4,
    username: 'username3',
    profileImage: null,
    isCurrent: false,
  ),
  lastMessage: _message3,
  unreadCount: 1,
);

const _message1 = Message(
  id: 0,
  user: User(id: 0, username: 'username', profileImage: null, isCurrent: false),
  message: 'message1',
  chatId: 0,
  isRead: false,
  createdAt: 234234,
  editedAt: null,
);

const _message2 = Message(
  id: 1,
  user: User(id: 1, username: 'username2', profileImage: null, isCurrent: false),
  message: 'message2',
  chatId: 1,
  isRead: false,
  createdAt: 2342349,
  editedAt: null,
);

const _message3 = Message(
  id: 2,
  user: User(id: 4, username: 'username3', profileImage: null, isCurrent: false),
  message: 'message3',
  chatId: 2,
  isRead: false,
  createdAt: 2342348,
  editedAt: null,
);

const _message4 = Message(
  id: 22,
  user: User(id: 12, username: 'username', profileImage: '', isCurrent: true),
  message: 'message to read',
  chatId: 0,
  isRead: false,
  createdAt: 999,
  editedAt: null,
);

const _chatsList1 = [
  Chat(
    id: 0,
    otherUser: User(
      id: 0,
      username: 'other_username',
      profileImage: null,
      isCurrent: false,
    ),
    lastMessage: null,
    unreadCount: 2,
  ),
  Chat(
    id: 1,
    otherUser: User(
      id: 1,
      username: 'other_username_2',
      profileImage: 'profile_image',
      isCurrent: false,
    ),
    lastMessage: null,
    unreadCount: 3,
  ),
];
