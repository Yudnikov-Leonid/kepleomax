// dart format width=200

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kepleomax/core/app.dart';
import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/data/db/local_database_manager.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/di/initialize_dependencies.dart';
import 'package:kepleomax/core/flavor.dart';
import 'package:kepleomax/core/mocks/mock_messages_web_socket.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/websockets/models/deleted_message_update.dart';
import 'package:mockito/mockito.dart';
import 'package:retrofit/dio.dart';

import 'utils/mock_objects.dart';
import 'utils/utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('chat_screen_tests', () {
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

    tearDown(() async {
      await LocalDatabaseManager.reset();
    });

    Future<void> setupApp(WidgetTester tester, ChatDto chat, List<MessageDto> messages, {Duration getMessagesDelay = Duration.zero}) async {
      when(dp.chatsApi.getChats()).thenAnswer((_) async {
        return HttpResponse(ChatsResponse(data: [chat], message: null), Response(requestOptions: RequestOptions(), statusCode: 200));
      });
      when(dp.messagesApi.getMessages(chatId: chat.id, limit: AppConstants.messagesPagingCount, cursor: null)).thenAnswer((_) async {
        await Future.delayed(getMessagesDelay);
        return HttpResponse(MessagesResponse(data: messages, message: null), Response(requestOptions: RequestOptions(), statusCode: 200));
      });
      await tester.pumpWidget(dp.inject(child: const App()));
      ws.setIsConnected(true);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('chat_${chat.id}')));
      if (getMessagesDelay == Duration.zero) {
        await tester.pumpAndSettle();
      } else {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('connection_test', (tester) async {
      /// after setup app will be connected to the ws, because the app must be connected to open the chat
      await setupApp(tester, chatDto0, [messageDto0, messageDto1, messageDto2, messageDto3, messageDto4], getMessagesDelay: const Duration(milliseconds: 150));

      /// check
      tester.checkChatAppBarStatus(ChatAppBarStatus.updating);
      tester.checkMessagesCount(1); // cached from chat
      tester.checkMessagesOrder([0]);

      /// wait for the response of the repository, check
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      tester.checkChatAppBarStatus(ChatAppBarStatus.none);
      tester.checkMessagesCount(5);
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);

      /// disconnect, check
      ws.setIsConnected(false);
      await tester.pump();
      tester.checkChatAppBarStatus(ChatAppBarStatus.connecting);
      tester.checkMessagesCount(5);
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);

      /// connect, check
      ws.setIsConnected(true);
      await tester.pump();
      tester.checkChatAppBarStatus(ChatAppBarStatus.updating);
      tester.checkMessagesCount(5);
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);

      /// wait for the response of the repository, check
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      tester.checkChatAppBarStatus(ChatAppBarStatus.none);
      tester.checkMessagesCount(5);
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);
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

      /// check messages, click submit (with empty text), check
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);
      await tester.tap(find.byKey(const Key('submit_message_button')));
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([0, 1, 2, 3, 4]);

      /// enter text, send, check
      ws.setNextSendMessageId(10);
      await tester.enterText(find.byKey(const Key('message_input_field')), 'NEW_MSG');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('submit_message_button')));
      await tester.pumpAndSettle();
      tester.checkMessagesOrder([10, 0, 1, 2, 3, 4]);
      tester.getMessage(10).check(fromCurrentUser: true, isRead: false, message: 'NEW_MSG');
    });

    testWidgets('check_read_messages', (tester) async {
      await setupApp(tester, chatDto0, [messageDto0, messageDto1, messageDto2, messageDto3, messageDto4]);

      /// check
      // await tester.pumpAndSettle(const Duration(milliseconds: 500)); think I don't need this
      expect(ws.readBeforeTimeCalledTimes, 1);
      expect(ws.isRaadBeforeTimeWasCalledWith(0, DateTime.fromMillisecondsSinceEpoch(messageDto0.createdAt)), true);
    });

    testWidgets('check_read_all_button', (tester) async {
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
      ws.addDeletedMessagesUpdate(DeletedMessageUpdate(chatId: 0, deletedMessage: messageDto3, newLastMessage: null));
      await tester.pump();
      tester.checkMessagesOrder([0, 1, 2, 4]);

      /// delete, check
      ws.addDeletedMessagesUpdate(DeletedMessageUpdate(chatId: 0, deletedMessage: messageDto2, newLastMessage: null));
      await tester.pump();
      tester.checkMessagesOrder([0, 1, 4]);
    });

    testWidgets('delete_message_test', (tester) async {
      await setupApp(tester, chatDto0, [messageDto0, messageDto1, messageDto2, messageDto3, messageDto4]);

      await tester.tap(find.descendant(of: tester.getMessage(4).finder, matching: find.byType(InkWell)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_message_popup_button')));
      await tester.pumpAndSettle();
      expect(ws.deleteMessageCalledTimes, 1);
      expect(ws.isDeleteMessageCalledWith(4), true);
    });
  });
}
