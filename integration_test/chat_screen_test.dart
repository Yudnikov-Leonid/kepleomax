// dart format width=200

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kepleomax/core/app.dart';
import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/data/local_data_sources/local_database_manager.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/di/initialize_dependencies.dart';
import 'package:kepleomax/core/flavor.dart';
import 'package:kepleomax/core/mocks/mock_messages_web_socket.dart';
import 'package:kepleomax/core/mocks/mockito_mocks.mocks.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/websockets/models/deleted_message_update.dart';
import 'package:kepleomax/core/network/websockets/models/new_message_update.dart';
import 'package:kepleomax/core/network/websockets/models/online_status_update.dart';
import 'package:kepleomax/core/network/websockets/models/typing_activity_update.dart';
import 'package:kepleomax/features/chats/chats_screen_navigator.dart';
import 'package:mockito/mockito.dart';
import 'package:retrofit/dio.dart';

import 'utils/mock_objects.dart';
import 'utils/utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized().framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('chat_screen_tests', () {
    late Dependencies dp;
    late MockMessagesWebSocket ws;
    late Completer<void> _getMessagesCompleter;

    setUpAll(() {
      Flavor.setFlavor(Flavor.testing());
    });

    setUp(() async {
      dp = await initializeDependencies(useMocks: true);
      ws = dp.messagesWebSocket as MockMessagesWebSocket;
      await dp.authController.setUser(User.testing());
    });

    tearDown(() async {
      await LocalDatabaseManager.reset();
    });

    Future<void> setupApp(WidgetTester tester, ChatDto? chat, List<MessageDto> messages, {bool getMessagesAsyncControl = false}) async {
      when(dp.chatsApi.getChats()).thenAnswer((_) async {
        return HttpResponse(ChatsResponse(data: chat == null ? [] : [chat], message: null), Response(requestOptions: RequestOptions(), statusCode: 200));
      });
      when((dp.chatsApi as MockChatsApi).getChatWithId(chatId: anyNamed('chatId'))).thenAnswer((inv) async {
        return HttpResponse(
          ChatResponse(data: [chatDto0, chatDto1, chatDto2, chatDto3, chatDto4].firstWhere((chat) => chat.id == inv.namedArguments[#chatId]), message: null),
          Response(requestOptions: RequestOptions(), statusCode: 200),
        );
      });
      when(dp.messagesApi.getMessages(chatId: chat?.id ?? 0, limit: AppConstants.msgPagingLimit, cursor: null)).thenAnswer((_) async {
        if (getMessagesAsyncControl) {
          _getMessagesCompleter = Completer();
          await _getMessagesCompleter.future;
        }
        return HttpResponse(MessagesResponse(data: messages, message: null), Response(requestOptions: RequestOptions(), statusCode: 200));
      });
      await tester.pumpWidget(dp.inject(child: const App()));
      ws.setIsConnected(true);
      await tester.pumpAndSettle();
      if (chat == null) return;
      await tester.tap(find.byKey(Key('chat_${chat.id}')));
      if (getMessagesAsyncControl) {
        /// 50 millis to end page opening animation. Settle doesn't work cause skeletonizer
        await tester.pump(const Duration(milliseconds: 50));
      } else {
        await tester.pumpAndSettle();
      }
    }

    void getChatWithUserMustReturn(ChatDto? chat, {int userId = 1}) {
      when(
        dp.chatsApi.getChatWithUser(otherUserId: userId),
      ).thenAnswer((_) async => HttpResponse(ChatResponse(data: chat, message: null), Response(requestOptions: RequestOptions(), statusCode: chat == null ? 404 : 200)));
    }

    Future<void> sendGetMessagesResponse(WidgetTester tester) async {
      _getMessagesCompleter.complete();
      await tester.pumpAndSettle();
    }

    testWidgets('connection_test', (tester) async {
      /// after setup app will be connected to the ws, because the app must be connected to open the chat
      await setupApp(tester, chatDto0, [messageDto0, messageDto1, messageDto2, messageDto3, messageDto4], getMessagesAsyncControl: true);

      /// check
      tester
        ..checkChatAppBarStatus(ChatAppBarStatus.updating)
        ..checkMessagesOrder([0]); // cached from chat

      /// wait for the response of the repository, check
      await sendGetMessagesResponse(tester);
      tester
        ..checkChatAppBarStatus(ChatAppBarStatus.none)
        ..checkMessagesCount(5)
        ..checkMessagesOrder([0, 1, 2, 3, 4]);

      /// disconnect, check
      ws.setIsConnected(false);
      await tester.pump();
      tester
        ..checkChatAppBarStatus(ChatAppBarStatus.connecting)
        ..checkMessagesCount(5)
        ..checkMessagesOrder([0, 1, 2, 3, 4]);

      /// connect, check
      ws.setIsConnected(true);
      await tester.pump();
      tester
        ..checkChatAppBarStatus(ChatAppBarStatus.updating)
        ..checkMessagesCount(5)
        ..checkMessagesOrder([0, 1, 2, 3, 4]);

      /// wait for the response of the repository, check
      await tester.pump(const Duration(milliseconds: 10)); // need this line
      await sendGetMessagesResponse(tester);
      tester
        ..checkChatAppBarStatus(ChatAppBarStatus.none)
        ..checkMessagesCount(5)
        ..checkMessagesOrder([0, 1, 2, 3, 4]);
    });

    testWidgets('message_statuses_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto0, messageDto1, messageDto2, messageDto3, messageDto4]);

      /// check
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);
      tester.getMessage(0).check(fromCurrentUser: false, message: 'MSG_0');
      tester.getMessage(1).check(fromCurrentUser: false, message: 'MSG_1');
      tester.getMessage(2).check(fromCurrentUser: false, message: 'MSG_2');
      tester.getMessage(3).check(fromCurrentUser: true, isRead: false, message: 'MSG_3');
      tester.getMessage(4).check(fromCurrentUser: true, isRead: true, message: 'MSG_4');
    });

    testWidgets('new_message_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto0, messageDto1, messageDto2, messageDto3, messageDto4]);

      /// check messages, check send_button is missing
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);
      expect(find.byKey(const Key('send_message_button')), findsNothing);

      /// enter text, send, check
      ws.setNextSendMessageId(10);
      await tester.enterText(find.byKey(const Key('message_input_field')), 'NEW_MSG');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([10, 0, 1, 2, 3, 4]);
      tester.getMessage(10).check(fromCurrentUser: true, isRead: false, message: 'NEW_MSG');
    });

    testWidgets('new_message_from_other_chat_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto0, messageDto1, messageDto2, messageDto3, messageDto4]);

      /// check, send message from anotherUser, check
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);
      ws.addMessage(const MessageDto(id: 10, chatId: 1, senderId: 1, isCurrentUser: false, message: 'MSG_10', isRead: false, createdAt: 1500, editedAt: null, fromCache: false));
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);

      /// send message from currentUser, check
      ws.addMessage(const MessageDto(id: 11, chatId: 1, senderId: 0, isCurrentUser: true, message: 'MSG_11', isRead: false, createdAt: 1550, editedAt: null, fromCache: false));
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);
    });

    testWidgets('read_messages_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto0, messageDto2, messageDto3, messageDto4], getMessagesAsyncControl: true);

      /// check (with cache messages should not work), send apiMessages, check
      expect(ws.readBeforeTimeCalledTimes, 0);
      await sendGetMessagesResponse(tester);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(ws.readBeforeTimeCalledTimes, 1);
      expect(ws.isRaadBeforeTimeWasCalledWith(0, DateTime.fromMillisecondsSinceEpoch(messageDto0.createdAt)), true);
    });

    testWidgets('read_all_button_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto0, messageDto1, messageDto2, messageDto3, messageDto4]);

      /// check, tap, check
      expect(ws.readAllCalledTimes, 0);
      await tester.tap(find.byKey(const Key('read_all_button')));
      await tester.pump();
      expect(ws.readAllCalledTimes, 1);
      expect(ws.isReadAllCalledWith(0), true);
    });

    testWidgets('deleted_message_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto0, messageDto1, messageDto2, messageDto3, messageDto4]);

      /// check, delete, check
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);
      ws.addDeletedMessagesUpdate(const DeletedMessageUpdate(chatId: 0, deletedMessage: messageDto3, newLastMessage: null));
      await tester.pump();
      tester.checkMessagesOrder([0, 1, 2, 4]);

      /// delete, check
      ws.addDeletedMessagesUpdate(const DeletedMessageUpdate(chatId: 0, deletedMessage: messageDto2, newLastMessage: null));
      await tester.pump();
      tester.checkMessagesOrder([0, 1, 4]);
    });

    testWidgets('delete_message_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto0, messageDto1, messageDto2, messageDto3, messageDto4]);

      /// tap, check
      await tester.tap(find.descendant(of: tester.getMessage(4).finder, matching: find.byType(InkWell)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_message_popup_button')));
      await tester.pumpAndSettle();
      expect(ws.deleteMessageCalledTimes, 1);
      expect(ws.isDeleteMessageCalledWith(4), true);
    });

    testWidgets('delete_cached_message_from_chat_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto2, messageDto3, messageDto4], getMessagesAsyncControl: true);

      /// we have cachedMessage with id 0 from chat. This message won't be received
      /// from api, so it should be deleted from cache
      tester.checkMessagesOrder([0]);
      await sendGetMessagesResponse(tester);
      tester.checkMessagesOrder([2, 3, 4]);

      /// go back, open chat, check cache, check loaded messages
      await tester.reopenChat(settle: false);
      tester
        ..checkMessagesOrder([2, 3, 4])
        ..checkChatAppBarStatus(ChatAppBarStatus.updating);
      await sendGetMessagesResponse(tester);
      tester
        ..checkMessagesOrder([2, 3, 4])
        ..checkChatAppBarStatus(ChatAppBarStatus.none);
    });

    testWidgets('unread_messages_widget_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto1, messageDto2, messageDto3, messageDto4]);

      tester.checkMessagesOrder([1, Message.unreadMessagesId, 2, 3, 4, Message.dateId], countSystem: true);
      ws.addMessage(messageDto0);
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([0, 1, Message.unreadMessagesId, 2, 3, 4, Message.dateId], countSystem: true);
    });

    testWidgets('no_unread_messages_widget_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto2, messageDto3, messageDto4]);

      tester.checkMessagesOrder([2, 3, 4, Message.dateId], countSystem: true);
      ws.addMessage(messageDto1);
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([1, 2, 3, 4, Message.dateId], countSystem: true);
    });

    testWidgets('unread_messages_widget_test_empty_chat_test', (tester) async {
      await setupApp(tester, chatDto0, []);

      tester.checkMessagesOrder([], countSystem: true);
      ws.addMessage(messageDto1);
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([1, Message.unreadMessagesId, Message.dateId], countSystem: true);

      ws.addMessage(messageDto0);
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([0, 1, Message.unreadMessagesId, Message.dateId], countSystem: true);
    });

    testWidgets('online_status_test', (tester) async {
      await setupApp(tester, chatDto0, []);

      /// check, add onlineUpdate: false, check
      tester.checkChatOtherUserStatus('online');
      ws.addOnlineUpdate(const OnlineStatusUpdate(userId: 1, isOnline: false, lastActivityTime: 0));
      await tester.pumpAndSettle();
      tester.checkChatOtherUserStatus('last seen a long time ago');

      /// add onlineUpdate: true, check, wait, check
      ws.addOnlineUpdate(OnlineStatusUpdate(userId: 1, isOnline: true, lastActivityTime: DateTime.now().millisecondsSinceEpoch - (AppConstants.markAsOfflineAfterInactivityInSeconds - 1) * 1000));
      await tester.pumpAndSettle();
      tester.checkChatOtherUserStatus('online');
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));
      tester.checkChatOtherUserStatus('last seen at');
    });

    /// can't check newMessage here, cause when new_message event is received,
    /// websocket handles it as both newMessage and typingActivity: set to false
    /// there is a mockWebsocket, so can't check its own handlers of events
    testWidgets('typing_test', (tester) async {
      await setupApp(tester, chatDto0, []);

      /// check, add typingUpdate, check
      tester.checkChatOtherUserStatus('online');
      ws.addTypingUpdate(const TypingActivityUpdate(chatId: 0, isTyping: true));
      await tester.pumpAndSettle();
      tester.checkChatOtherUserStatus('typing..');

      /// add typingUpdate, check
      ws.addTypingUpdate(const TypingActivityUpdate(chatId: 0, isTyping: false));
      await tester.pumpAndSettle();
      tester.checkChatOtherUserStatus('online');

      /// add typingUpdate, check, wait, check
      ws.addTypingUpdate(const TypingActivityUpdate(chatId: 0, isTyping: true));
      await tester.pumpAndSettle();
      tester.checkChatOtherUserStatus('typing..');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      tester.checkChatOtherUserStatus('typing..');
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));
      tester.checkChatOtherUserStatus('online');
    });

    testWidgets('new_chat_other_user_message_first_test', (tester) async {
      await setupApp(tester, null, [], getMessagesAsyncControl: true);
      await dp.usersLocalDataSource.insert(chatDto0.otherUser);
      getChatWithUserMustReturn(null);

      /// open new chat, check
      await tester.navigateTo(ChatPage(chatId: -1, otherUser: User.fromDto(chatDto0.otherUser)));
      tester.checkMessagesOrder([]);

      /// add message, check
      getChatWithUserMustReturn(chatDto0);
      ws.addMessage(messageDto0, createdChatInfo: CreatedChatInfo(chatId: 0, usersIds: [0, messageDto0.senderId]));
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([0]);

      /// add message, check
      ws.addMessage(messageDto3);
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([3, 0]);

      /// add message, check
      ws.addMessage(messageDto1);
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([1, 3, 0]);

      /// reopen chat, check cache
      await tester.reopenChat(settle: false);
      // messages will be sorted by time, so order will be changed
      tester.checkMessagesOrder([0, 1, 3]);
    });

    testWidgets('new_chat_current_user_message_first_test', (tester) async {
      await setupApp(tester, null, []);
      await dp.usersLocalDataSource.insert(chatDto0.otherUser);
      getChatWithUserMustReturn(null);

      /// open new chat, check
      await tester.navigateTo(ChatPage(chatId: -1, otherUser: User.fromDto(chatDto0.otherUser)));
      tester.checkMessagesOrder([]);

      /// add message, check
      getChatWithUserMustReturn(chatDto0);
      ws.addMessage(messageDto3, createdChatInfo: CreatedChatInfo(chatId: 0, usersIds: [0, messageDto0.senderId]));
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([3]);

      /// add message, check
      ws.addMessage(messageDto1);
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([1, 3]);
    });

    testWidgets('delete_last_message_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto0]);

      tester.checkMessagesOrder([0]);
      ws.addDeletedMessagesUpdate(const DeletedMessageUpdate(chatId: 0, deletedMessage: messageDto0, newLastMessage: null, deleteChat: true));
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([]);
      await tester.goBack();
      tester.checkChatsOrder([]);
    });

    testWidgets('delete_last_message_and_send_new_one_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto0]);

      tester.checkMessagesOrder([0]);
      ws.addDeletedMessagesUpdate(const DeletedMessageUpdate(chatId: 0, deletedMessage: messageDto0, newLastMessage: null, deleteChat: true));
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([]);

      getChatWithUserMustReturn(chatDto0);
      ws.addMessage(messageDto1, createdChatInfo: CreatedChatInfo(chatId: 0, usersIds: [0, chatDto0.otherUser.id]));
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([1]);

      await tester.goBack();
      tester.getChat(0).check(message: chatDto0.lastMessage!.message);
    });

    /// TODO system dates messages test
    /// TODO base paging test
    /// paging is tested via unit-tests
  });
}
