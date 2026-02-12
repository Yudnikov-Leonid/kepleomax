// dart format width=200

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kepleomax/core/app.dart';
import 'package:kepleomax/core/data/db/local_database_manager.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/di/initialize_dependencies.dart';
import 'package:kepleomax/core/flavor.dart';
import 'package:kepleomax/core/mocks/mock_messages_web_socket.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/websockets/models/deleted_message_update.dart';
import 'package:kepleomax/core/network/websockets/models/read_messages_update.dart';
import 'package:mockito/mockito.dart';
import 'package:retrofit/dio.dart';

import 'utils/mock_objects.dart';
import 'utils/utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('chats_screen_tests', () {
    late Dependencies dp;
    late MockMessagesWebSocket ws;
    Duration _cachedGetChatsDelay = Duration.zero;

    setUpAll(() {
      Flavor.setFlavor(Flavor.testing());
    });

    setUp(() async {
      dp = await initializeDependencies(useMocks: true);
      ws = dp.messagesWebSocket as MockMessagesWebSocket;
      dp.authController.setUser(User.testing());
    });

    tearDown(() {
      _cachedGetChatsDelay = Duration.zero;
      LocalDatabaseManager.reset();
    });

    Future<void> setupAppWithChats(WidgetTester tester, List<ChatDto> chats, {Duration getChatsDelay = Duration.zero}) async {
      _cachedGetChatsDelay = getChatsDelay;
      when(dp.chatsApi.getChats()).thenAnswer((_) async {
        await Future.delayed(getChatsDelay);
        return HttpResponse(ChatsResponse(data: chats, message: null), Response(requestOptions: RequestOptions(), statusCode: 200));
      });
      await tester.pumpWidget(dp.inject(child: const App()));
      ws.setIsConnected(true);
      if (getChatsDelay == Duration.zero) {
        await tester.pumpAndSettle();
      } else {
        await tester.pump();
      }
    }

    void changeGetChatsResponse(List<ChatDto> chats) {
      when(dp.chatsApi.getChats()).thenAnswer((_) async {
        await Future.delayed(_cachedGetChatsDelay);
        return HttpResponse(ChatsResponse(data: chats, message: null), Response(requestOptions: RequestOptions(), statusCode: 200));
      });
    }

    Future<void> restartApp(WidgetTester tester) async {
      ws.setIsConnected(false);
      await tester.pumpWidget(dp.inject(child: const App()));
      ws.setIsConnected(true);
      await tester.pump();
    }

    testWidgets('connection_test', (tester) async {
      when(dp.chatsApi.getChats()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 150));
        return HttpResponse(ChatsResponse(data: [], message: null), Response(requestOptions: RequestOptions(), statusCode: 200));
      });
      await tester.pumpWidget(dp.inject(child: const App()));
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.connecting);
      tester.checkFindPeopleButton(isShown: false);

      /// connect, check
      ws.setIsConnected(true);
      await tester.pump(const Duration(milliseconds: 100));
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.updating);
      tester.checkFindPeopleButton(isShown: false);

      /// wait for the response of the repository, check
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.chats);
      tester.checkFindPeopleButton(isShown: true);

      /// disconnect, check
      ws.setIsConnected(false);
      await tester.pump(const Duration(milliseconds: 100));
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.connecting);
      tester.checkFindPeopleButton(isShown: true);

      /// connect, check
      ws.setIsConnected(true);
      await tester.pump(const Duration(milliseconds: 100));
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.updating);
      tester.checkFindPeopleButton(isShown: false);

      /// wait for the response of the repository, check
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.chats);
      tester.checkFindPeopleButton(isShown: true);
    });

    testWidgets('chats_statuses_test', (tester) async {
      await setupAppWithChats(tester, [chatDto0, chatDto1, chatDto2, chatDto3, chatDto4]);

      /// check
      tester.checkChatsOrder([0, 1, 2, 3, 4]);
      tester.getChat(0).check(unreadCount: 2, unreadIcon: false, readIcon: false, message: 'MSG_0', msgFromCurrentUser: false, otherUserName: 'OTHER_USERNAME_1');
      tester.getChat(1).check(unreadCount: 4, unreadIcon: false, readIcon: false, message: 'MSG_1', msgFromCurrentUser: false, otherUserName: 'OTHER_USERNAME_2');
      tester.getChat(2).check(unreadCount: 0, unreadIcon: true, readIcon: false, message: 'MSG_2', msgFromCurrentUser: true, otherUserName: 'OTHER_USERNAME_3');
      tester.getChat(3).check(unreadCount: 0, unreadIcon: false, readIcon: true, message: 'MSG_3', msgFromCurrentUser: true, otherUserName: 'OTHER_USERNAME_4');
      tester.getChat(4).check(unreadCount: 0, unreadIcon: false, readIcon: false, message: 'MSG_4', msgFromCurrentUser: false, otherUserName: 'OTHER_USERNAME_5');
    });

    testWidgets('unread_count_test', (tester) async {
      await setupAppWithChats(tester, [chatDto0, chatDto1, chatDto2, chatDto3, chatDto4]);
      tester.checkTotalUnreadCount(6);
    });

    testWidgets('new_message_test', (tester) async {
      await setupAppWithChats(tester, [chatDto0, chatDto1, chatDto2, chatDto3, chatDto4]);

      /// check chat
      tester.checkChatsOrder([0, 1, 2, 3, 4]);
      tester.getChat(4).check(unreadCount: 0, unreadIcon: false, readIcon: false, message: 'MSG_4', msgFromCurrentUser: false);

      /// add message
      ws.addMessage(
        MessageDto(id: 5, chatId: chatDto4.id, senderId: chatDto4.otherUser.id, isCurrentUser: false, message: 'MSG_5', isRead: false, createdAt: 1100, editedAt: null, fromCache: false),
      );
      await tester.pumpAndSettle();

      /// check chat again
      tester.checkChatsOrder([4, 0, 1, 2, 3]);
      tester.getChat(4).check(unreadCount: 1, unreadIcon: false, readIcon: false, message: 'MSG_5', msgFromCurrentUser: false);
      tester.checkTotalUnreadCount(7);
    });

    testWidgets('read_message_test', (tester) async {
      await setupAppWithChats(tester, [chatDto0]);

      /// check chat
      tester.getChat(0).check(unreadCount: 2);
      tester.checkTotalUnreadCount(2);

      /// add readMessages, check chat
      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: chatDto0.id, senderId: chatDto0.otherUser.id, isCurrentUser: false, messagesIds: [999]));
      await tester.pumpAndSettle();
      tester.getChat(0).check(unreadCount: 1);
      tester.checkTotalUnreadCount(1);

      /// add readMessages, check chat again
      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: chatDto0.id, senderId: chatDto0.otherUser.id, isCurrentUser: false, messagesIds: [chatDto0.lastMessage!.id]));
      await tester.pumpAndSettle();
      tester.getChat(0).check(unreadCount: 0, unreadIcon: false, readIcon: false); // both was false and now still are false
      tester.checkTotalUnreadCount(0);
    });

    testWidgets('read_current_user_messages_test', (tester) async {
      await setupAppWithChats(tester, [chatDto0, chatDto2]);

      /// check chat
      tester.getChat(0).check(unreadCount: 2);
      tester.checkTotalUnreadCount(2);

      /// add readMessages, check chat
      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: chatDto0.id, senderId: 0, isCurrentUser: true, messagesIds: [999]));
      await tester.pumpAndSettle();
      tester.getChat(0).check(unreadCount: 2);
      tester.checkTotalUnreadCount(2);

      /// check chat2, add readMessages, check chat2
      tester.getChat(2).check(unreadIcon: true, readIcon: false);
      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: chatDto2.id, senderId: 0, isCurrentUser: true, messagesIds: [999]));
      await tester.pumpAndSettle();
      tester.getChat(2).check(unreadIcon: true, readIcon: false);
      tester.checkTotalUnreadCount(2);

      /// add readMessages, check chat2
      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: chatDto2.id, senderId: 0, isCurrentUser: true, messagesIds: [chatDto2.lastMessage!.id]));
      await tester.pumpAndSettle();
      tester.getChat(2).check(unreadIcon: false, readIcon: true);
      tester.checkTotalUnreadCount(2);
    });

    testWidgets('10000_unread_messages_test', (tester) async {
      await setupAppWithChats(tester, [ChatDto(id: chatDto0.id, otherUser: chatDto0.otherUser, lastMessage: chatDto0.lastMessage, unreadCount: 10000)]);

      /// check
      tester.getChat(0).check(unreadCount: 999);
      tester.checkTotalUnreadCount(99);
    });

    /**
     * if deletedMessage from otherUser && unread -> should decrease unreadCount
     * if newLastMessage != null -> new lastMessage of chat should be set to that
     */
    testWidgets('delete_messages_test', (tester) async {
      await setupAppWithChats(tester, [chatDto0]);

      /// check, delete currentUser message, check
      tester.getChat(0).check(unreadCount: 2);
      ws.addDeletedMessagesUpdate(
        const DeletedMessageUpdate(
          chatId: 0,
          deletedMessage: MessageDto(id: 999, chatId: 0, senderId: 0, isCurrentUser: true, message: '', isRead: true, createdAt: 999, editedAt: null, fromCache: false),
          newLastMessage: null,
        ),
      );
      await tester.pumpAndSettle();
      tester.getChat(0).check(unreadCount: 2);

      /// delete otherUser unread message, check
      ws.addDeletedMessagesUpdate(
        const DeletedMessageUpdate(
          chatId: 0,
          deletedMessage: MessageDto(id: 999, chatId: 0, senderId: 0, isCurrentUser: false, message: '', isRead: false, createdAt: 999, editedAt: null, fromCache: false),
          newLastMessage: null,
        ),
      );
      await tester.pumpAndSettle();
      tester.getChat(0).check(unreadCount: 1);

      /// delete otherUser read message, check
      ws.addDeletedMessagesUpdate(
        const DeletedMessageUpdate(
          chatId: 0,
          deletedMessage: MessageDto(id: 999, chatId: 0, senderId: 0, isCurrentUser: false, message: '', isRead: true, createdAt: 999, editedAt: null, fromCache: false),
          newLastMessage: null,
        ),
      );
      await tester.pumpAndSettle();
      tester.getChat(0).check(unreadCount: 1);

      /// check, delete currentUser message with newLastMessage from otherUser, check
      tester.getChat(0).check(message: chatDto0.lastMessage!.message);
      ws.addDeletedMessagesUpdate(
        const DeletedMessageUpdate(
          chatId: 0,
          deletedMessage: MessageDto(id: 999, chatId: 0, senderId: 0, isCurrentUser: false, message: '', isRead: true, createdAt: 999, editedAt: null, fromCache: false),
          newLastMessage: MessageDto(id: 998, chatId: 0, senderId: 0, isCurrentUser: false, message: 'NEW_MSG', isRead: false, createdAt: 999, editedAt: null, fromCache: false),
        ),
      );
      await tester.pumpAndSettle();
      tester.getChat(0).check(message: 'NEW_MSG', msgFromCurrentUser: false);
      tester.getChat(0).check(unreadCount: 1);

      /// delete otherUser unread message with newLastMessage from currentUser, check
      ws.addDeletedMessagesUpdate(
        const DeletedMessageUpdate(
          chatId: 0,
          deletedMessage: MessageDto(id: 999, chatId: 0, senderId: 0, isCurrentUser: false, message: '', isRead: false, createdAt: 999, editedAt: null, fromCache: false),
          newLastMessage: MessageDto(id: 998, chatId: 0, senderId: 0, isCurrentUser: true, message: 'NEW_MSG_2', isRead: true, createdAt: 999, editedAt: null, fromCache: false),
        ),
      );
      await tester.pumpAndSettle();
      tester.getChat(0).check(message: 'NEW_MSG_2', msgFromCurrentUser: true);
      tester.getChat(0).check(unreadCount: 0);
    });

    testWidgets('delete_messages_chats_order_test', (tester) async {
      await setupAppWithChats(tester, [chatDto0, chatDto1, chatDto2, chatDto3, chatDto4]);

      /// current createdAts: [1090, 1080, 1070, 1060, 1050]
      /// check order, add newLastMessage to chat 0 with createdAt 1000, check order
      tester.checkChatsOrder([0, 1, 2, 3, 4]);
      ws.addDeletedMessagesUpdate(
        const DeletedMessageUpdate(
          chatId: 0,
          deletedMessage: MessageDto(id: 999, chatId: 0, senderId: 0, isCurrentUser: false, message: '', isRead: false, createdAt: 999, editedAt: null, fromCache: false),
          newLastMessage: MessageDto(id: 999, chatId: 0, senderId: 0, isCurrentUser: false, message: '', isRead: false, createdAt: 1000, editedAt: null, fromCache: false),
        ),
      );
      await tester.pumpAndSettle();
      tester.checkChatsOrder([1, 2, 3, 4, 0]);

      /// current createdAts: [1080, 1070, 1060, 1050, 1000]
      /// check order, add newLastMessage to chat 2 with createdAt 1055, check order
      ws.addDeletedMessagesUpdate(
        const DeletedMessageUpdate(
          chatId: 2,
          deletedMessage: MessageDto(id: 999, chatId: 2, senderId: 0, isCurrentUser: false, message: '', isRead: false, createdAt: 999, editedAt: null, fromCache: false),
          newLastMessage: MessageDto(id: 999, chatId: 2, senderId: 0, isCurrentUser: false, message: '', isRead: false, createdAt: 1055, editedAt: null, fromCache: false),
        ),
      );
      await tester.pumpAndSettle();
      tester.checkChatsOrder([1, 3, 2, 4, 0]);

      /// current createdAts: [1080, 1060, 1055, 1050, 1000]
      /// check order, add newLastMessage to chat 4 with createdAt 1052, check order
      ws.addDeletedMessagesUpdate(
        const DeletedMessageUpdate(
          chatId: 4,
          deletedMessage: MessageDto(id: 999, chatId: 4, senderId: 0, isCurrentUser: false, message: '', isRead: false, createdAt: 999, editedAt: null, fromCache: false),
          newLastMessage: MessageDto(id: 999, chatId: 4, senderId: 0, isCurrentUser: false, message: '', isRead: false, createdAt: 1052, editedAt: null, fromCache: false),
        ),
      );
      await tester.pumpAndSettle();
      tester.checkChatsOrder([1, 3, 2, 4, 0]);
    });

    testWidgets('cache_test', (tester) async {
      await setupAppWithChats(tester, [chatDto0, chatDto1, chatDto2, chatDto3, chatDto4], getChatsDelay: const Duration(milliseconds: 150));

      /// check no chats on first start
      expect(find.byKey(const Key('chats_loading')), findsOneWidget);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('chats_loading')), findsNothing);
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.chats);
      tester.checkChatsOrder([0, 1, 2, 3, 4]);

      /// check cachedChats, then new chats from api
      changeGetChatsResponse([chatDto4, chatDto3, chatDto2, chatDto1]);
      await restartApp(tester);
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.updating);
      tester.checkChatsOrder([0, 1, 2, 3, 4]);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.chats);
      tester.checkChatsOrder([4, 3, 2, 1]);
    });
    
    testWidgets('cache_new_message_test', (tester) async {
      await setupAppWithChats(tester, [chatDto0, chatDto1, chatDto2, chatDto3, chatDto4], getChatsDelay: const Duration(milliseconds: 150));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      /// check current chats
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.chats);
      tester.checkChatsOrder([0, 1, 2, 3, 4]);

      /// add new message, check chats
      final newMessage = const MessageDto(id: 999, chatId: 2, senderId: 0, isCurrentUser: true, message: 'MSG_999', isRead: false, createdAt: 1100, editedAt: null, fromCache: false);
      ws.addMessage(newMessage);
      await tester.pumpAndSettle();
      tester.checkChatsOrder([2, 0, 1, 3, 4]);
      tester.getChat(2).check(message: 'MSG_999', msgFromCurrentUser: true);

      /// check cachedChats, then new chats from api
      await restartApp(tester);
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.updating);
      tester.checkChatsOrder([2, 0, 1, 3, 4]);
      tester.getChat(2).check(message: 'MSG_999', msgFromCurrentUser: true);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.chats);
      tester.checkChatsOrder([0, 1, 2, 3, 4]);
      tester.getChat(2).check(message: chatDto2.lastMessage!.message, msgFromCurrentUser: chatDto2.lastMessage!.isCurrentUser);

      /// check cachedChats
      await restartApp(tester);
      tester.checkChatsAppBarStatus(ChatsAppBarStatus.updating);
      tester.checkChatsOrder([0, 1, 2, 3, 4]);
      tester.getChat(2).check(message: chatDto2.lastMessage!.message, msgFromCurrentUser: chatDto2.lastMessage!.isCurrentUser);
    });

    /// TODO message from the chat that's not loaded now (new one)
    /// TODO cache test with deleted message ?
    /// TODO error cases test ?
    /// TODO find people navigation test ?
  });
}