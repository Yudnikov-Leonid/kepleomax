// dart format width=200

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kepleomax/core/app.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/di/initialize_dependencies.dart';
import 'package:kepleomax/core/flavor.dart';
import 'package:kepleomax/core/mocks/mock_messages_web_socket.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';
import 'package:kepleomax/core/network/websockets/models/read_messages_update.dart';
import 'package:mockito/mockito.dart';
import 'package:retrofit/dio.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('chats_screen', () {
    late Dependencies dp;
    late MockMessagesWebSocket ws;

    setUpAll(() {
      Flavor.setFlavor(Flavor.testing());
    });

    setUp(() async {
      dp = await initializeDependencies(useMocks: true);
      ws = dp.messagesWebSocket as MockMessagesWebSocket;
      dp.authController.setUser(User.testing());
    });

    testWidgets('connection_test', (tester) async {
      when(dp.chatsApi.getChats()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 150));
        return HttpResponse(ChatsResponse(data: [], message: null), Response(requestOptions: RequestOptions(), statusCode: 200));
      });
      await tester.pumpWidget(dp.inject(child: const App()));
      tester.checkAppBarText('Connecting..');
      tester.checkFindPeopleButton(isShown: false);

      /// connect, check
      ws.setIsConnected(true);
      await tester.pump(const Duration(milliseconds: 100));
      tester.checkAppBarText('Updating..');
      tester.checkFindPeopleButton(isShown: false);

      /// wait for the response of the repository, check
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      tester.checkAppBarText('Chats');
      tester.checkFindPeopleButton(isShown: true);

      /// disconnect, check
      ws.setIsConnected(false);
      await tester.pump(const Duration(milliseconds: 100));
      tester.checkAppBarText('Connecting..');
      tester.checkFindPeopleButton(isShown: true);

      /// connect, check
      ws.setIsConnected(true);
      await tester.pump(const Duration(milliseconds: 100));
      tester.checkAppBarText('Updating..');
      tester.checkFindPeopleButton(isShown: false);

      /// wait for the response of the repository, check
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      tester.checkAppBarText('Chats');
      tester.checkFindPeopleButton(isShown: true);
    });

    testWidgets('chats_statuses_test, unread_counter_test', (tester) async {
      when(
        dp.chatsApi.getChats(),
      ).thenAnswer((_) async => HttpResponse(ChatsResponse(data: [_chatDto0, _chatDto1, _chatDto2, _chatDto3, _chatDto4], message: null), Response(requestOptions: RequestOptions(), statusCode: 200)));
      await tester.pumpWidget(dp.inject(child: const App()));
      ws.setIsConnected(true);
      await tester.pumpAndSettle();

      /// check
      tester.checkChatsOrder([0, 1, 2, 3, 4]);
      tester.checkTotalUnreadCount(6);
      tester.getChat(0).check(unreadCount: 2, unreadIcon: false, readIcon: false, message: 'MSG_0', msgFromCurrentUser: false, otherUserName: 'OTHER_USERNAME_1');
      tester.getChat(1).check(unreadCount: 4, unreadIcon: false, readIcon: false, message: 'MSG_1', msgFromCurrentUser: false, otherUserName: 'OTHER_USERNAME_2');
      tester.getChat(2).check(unreadCount: 0, unreadIcon: true, readIcon: false, message: 'MSG_2', msgFromCurrentUser: true, otherUserName: 'OTHER_USERNAME_3');
      tester.getChat(3).check(unreadCount: 0, unreadIcon: false, readIcon: true, message: 'MSG_3', msgFromCurrentUser: true, otherUserName: 'OTHER_USERNAME_4');
      tester.getChat(4).check(unreadCount: 0, unreadIcon: false, readIcon: false, message: 'MSG_4', msgFromCurrentUser: false, otherUserName: 'OTHER_USERNAME_5');
    });

    testWidgets('new_message_test', (tester) async {
      when(
        dp.chatsApi.getChats(),
      ).thenAnswer((_) async => HttpResponse(ChatsResponse(data: [_chatDto0, _chatDto1, _chatDto2, _chatDto3, _chatDto4], message: null), Response(requestOptions: RequestOptions(), statusCode: 200)));
      await tester.pumpWidget(dp.inject(child: const App()));
      ws.setIsConnected(true);
      await tester.pumpAndSettle();

      /// check chat
      tester.checkChatsOrder([0, 1, 2, 3, 4]);
      tester.getChat(4).check(unreadCount: 0, unreadIcon: false, readIcon: false, message: 'MSG_4', msgFromCurrentUser: false);

      /// add message
      ws.addMessage(
        MessageDto(id: 5, chatId: _chatDto4.id, senderId: _chatDto4.otherUser.id, isCurrentUser: false, message: 'MSG_5', isRead: false, createdAt: 1100, editedAt: null, fromCache: false),
      );
      await tester.pumpAndSettle();

      /// check chat again
      tester.checkChatsOrder([4, 0, 1, 2, 3]);
      tester.getChat(4).check(unreadCount: 1, unreadIcon: false, readIcon: false, message: 'MSG_5', msgFromCurrentUser: false);
      tester.checkTotalUnreadCount(7);
    });

    testWidgets('read_message_test', (tester) async {
      when(
        dp.chatsApi.getChats(),
      ).thenAnswer((_) async => HttpResponse(ChatsResponse(data: [_chatDto0, _chatDto1, _chatDto2], message: null), Response(requestOptions: RequestOptions(), statusCode: 200)));
      await tester.pumpWidget(dp.inject(child: const App()));
      ws.setIsConnected(true);
      await tester.pumpAndSettle();

      /// check chat
      tester.getChat(0).check(unreadCount: 2);
      tester.checkTotalUnreadCount(6);

      /// add readMessages, check chat
      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: _chatDto0.id, senderId: _chatDto0.otherUser.id, isCurrentUser: false, messagesIds: [999]));
      await tester.pumpAndSettle();
      tester.getChat(0).check(unreadCount: 1);
      tester.checkTotalUnreadCount(5);

      /// add readMessages, check chat again
      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: _chatDto0.id, senderId: _chatDto0.otherUser.id, isCurrentUser: false, messagesIds: [_chatDto0.lastMessage!.id]));
      await tester.pumpAndSettle();
      tester.getChat(0).check(unreadCount: 0, unreadIcon: false, readIcon: false); // both was false and now still are false
      tester.checkTotalUnreadCount(4);
    });

    testWidgets('read_current_user_message_test', (tester) async {
      when(
        dp.chatsApi.getChats(),
      ).thenAnswer((_) async => HttpResponse(ChatsResponse(data: [_chatDto0, _chatDto1, _chatDto2, _chatDto3], message: null), Response(requestOptions: RequestOptions(), statusCode: 200)));
      await tester.pumpWidget(dp.inject(child: const App()));
      ws.setIsConnected(true);
      await tester.pumpAndSettle();

      /// check chat
      tester.getChat(0).check(unreadCount: 2);
      tester.checkTotalUnreadCount(6);

      /// add readMessages, check chat
      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: _chatDto0.id, senderId: 0, isCurrentUser: true, messagesIds: [999]));
      await tester.pumpAndSettle();
      tester.getChat(0).check(unreadCount: 2);
      tester.checkTotalUnreadCount(6);

      /// check chat2, add readMessages, check chat2
      tester.getChat(2).check(unreadIcon: true, readIcon: false);
      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: _chatDto2.id, senderId: 0, isCurrentUser: true, messagesIds: [999]));
      await tester.pumpAndSettle();
      tester.getChat(2).check(unreadIcon: true, readIcon: false);
      tester.checkTotalUnreadCount(6);

      /// add readMessages, check chat2
      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: _chatDto2.id, senderId: 0, isCurrentUser: true, messagesIds: [_chatDto2.lastMessage!.id]));
      await tester.pumpAndSettle();
      tester.getChat(2).check(unreadIcon: false, readIcon: true);
      tester.checkTotalUnreadCount(6);
    });

    /// TODO remove message test
    /// TODO cache test
    /// TODO 999+ unread messages test
  });
}

final _chatDto0 = const ChatDto(
  id: 0,
  otherUser: UserDto(id: 1, username: 'OTHER_USERNAME_1', profileImage: null, isCurrent: false),
  lastMessage: MessageDto(id: 0, chatId: 0, senderId: 1, isCurrentUser: false, message: 'MSG_0', isRead: false, createdAt: 1099, editedAt: null, fromCache: false),
  unreadCount: 2,
);

final _chatDto1 = const ChatDto(
  id: 1,
  otherUser: UserDto(id: 2, username: 'OTHER_USERNAME_2', profileImage: null, isCurrent: false),
  lastMessage: MessageDto(id: 1, chatId: 1, senderId: 2, isCurrentUser: false, message: 'MSG_1', isRead: false, createdAt: 1098, editedAt: null, fromCache: false),
  unreadCount: 4,
);

final _chatDto2 = const ChatDto(
  id: 2,
  otherUser: UserDto(id: 3, username: 'OTHER_USERNAME_3', profileImage: null, isCurrent: false),
  lastMessage: MessageDto(id: 2, chatId: 2, senderId: 0, isCurrentUser: true, message: 'MSG_2', isRead: false, createdAt: 1097, editedAt: null, fromCache: false),
  unreadCount: 0,
);

final _chatDto3 = const ChatDto(
  id: 3,
  otherUser: UserDto(id: 4, username: 'OTHER_USERNAME_4', profileImage: null, isCurrent: false),
  lastMessage: MessageDto(id: 3, chatId: 3, senderId: 0, isCurrentUser: true, message: 'MSG_3', isRead: true, createdAt: 1096, editedAt: null, fromCache: false),
  unreadCount: 0,
);

final _chatDto4 = const ChatDto(
  id: 4,
  otherUser: UserDto(id: 5, username: 'OTHER_USERNAME_5', profileImage: null, isCurrent: false),
  lastMessage: MessageDto(id: 4, chatId: 4, senderId: 5, isCurrentUser: false, message: 'MSG_4', isRead: true, createdAt: 1095, editedAt: null, fromCache: false),
  unreadCount: 0,
);
