// dart format width=200

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
import 'package:kepleomax/features/chats/chats_screen.dart';
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
        await Future.delayed(const Duration(milliseconds: 300));
        return HttpResponse(ChatsResponse(data: [], message: null), Response(requestOptions: RequestOptions(), statusCode: 200));
      });
      await tester.pumpWidget(dp.inject(child: const App()));

      /// test connect
      expect(tester.textByKey(const Key('app_bar_text')), equals('Connecting..'));

      ws.setIsConnected(true);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.textByKey(const Key('app_bar_text')), equals('Updating..'));

      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(tester.textByKey(const Key('app_bar_text')), equals('Chats'));
      expect(find.byKey(const Key('find_people_button')), findsOneWidget);

      /// disconnect
      ws.setIsConnected(false);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.textByKey(const Key('app_bar_text')), equals('Connecting..'));

      /// connect
      ws.setIsConnected(true);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.textByKey(const Key('app_bar_text')), equals('Updating..'));

      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(tester.textByKey(const Key('app_bar_text')), equals('Chats'));
      expect(find.byKey(const Key('find_people_button')), findsOneWidget);
    });

    testWidgets('chats_statuses_test, unread_counter_test', (tester) async {
      when(
        dp.chatsApi.getChats(),
      ).thenAnswer((_) async => HttpResponse(ChatsResponse(data: [_chatDto0, _chatDto1, _chatDto2, _chatDto3, _chatDto4], message: null), Response(requestOptions: RequestOptions(), statusCode: 200)));
      await tester.pumpWidget(dp.inject(child: const App()));

      /// test
      ws.setIsConnected(true);
      await tester.pumpAndSettle();

      expect(find.byType(ChatWidget), findsNWidgets(5));
      expect(tester.textByKey(const Key('chats_unread_text')), equals('6'));
      expect(find.childrenWithText(const Key('chat-0'), '2'), findsOneWidget);
      expect(find.childrenWithText(const Key('chat-0'), 'MSG_0'), findsOneWidget);
      expect(find.childrenWithText(const Key('chat-0'), 'OTHER_USERNAME_1'), findsOneWidget);
      expect(find.childrenWithText(const Key('chat-1'), '4'), findsOneWidget);
      expect(find.childrenWithText(const Key('chat-1'), 'MSG_1'), findsOneWidget);
      expect(find.childrenWithText(const Key('chat-1'), 'OTHER_USERNAME_2'), findsOneWidget);
      expect(find.childrenWithIcon(const Key('chat-2'), Icons.check), findsOneWidget);
      expect(find.childrenWithText(const Key('chat-2'), 'MSG_2'), findsOneWidget);
      expect(find.childrenWithText(const Key('chat-2'), 'You: '), findsOneWidget);
      expect(find.childrenWithIcon(const Key('chat-3'), Icons.check_box), findsOneWidget);
      expect(find.childrenWithText(const Key('chat-3'), 'MSG_3'), findsOneWidget);
      expect(find.childrenWithText(const Key('chat-3'), 'You: '), findsOneWidget);
      expect(find.childrenWithIcon(const Key('chat-4'), Icons.check_box), findsNothing);
      expect(find.childrenWithIcon(const Key('chat-4'), Icons.check), findsNothing);
      expect(find.childrenWithText(const Key('chat-4'), 'MSG_4'), findsOneWidget);
      expect(find.childrenWithText(const Key('chat-4'), 'You: '), findsNothing);
      expect(find.childrenWithText(const Key('chat-4'), 'OTHER_USERNAME_5'), findsOneWidget);
    });

    testWidgets('new_message_test', (tester) async {
      when(
        dp.chatsApi.getChats(),
      ).thenAnswer((_) async => HttpResponse(ChatsResponse(data: [_chatDto0, _chatDto1, _chatDto2, _chatDto3, _chatDto4], message: null), Response(requestOptions: RequestOptions(), statusCode: 200)));
      await tester.pumpWidget(dp.inject(child: const App()));

      /// test
      ws.setIsConnected(true);
      await tester.pumpAndSettle();

      /// check chat
      expect(tester.keysOfListByKey(const Key('chats_list_view'), ChatWidget), equals([const Key('chat-0'), const Key('chat-1'), const Key('chat-2'), const Key('chat-3'), const Key('chat-4')]));
      expect(find.childrenWithIcon(const Key('chat-4'), Icons.check_box), findsNothing);
      expect(find.childrenWithIcon(const Key('chat-4'), Icons.check), findsNothing);
      expect(find.childrenWithText(const Key('chat-4'), 'You: '), findsNothing);

      /// addMessage
      ws.addMessage(
        MessageDto(id: 5, chatId: _chatDto4.id, senderId: _chatDto4.otherUser.id, isCurrentUser: false, message: 'MSG_5', isRead: false, createdAt: 1100, editedAt: null, fromCache: false),
      );
      await tester.pumpAndSettle();

      /// check chat again
      expect(tester.keysOfListByKey(const Key('chats_list_view'), ChatWidget), equals([const Key('chat-4'), const Key('chat-0'), const Key('chat-1'), const Key('chat-2'), const Key('chat-3')]));
      expect(find.childrenWithIcon(const Key('chat-4'), Icons.check_box), findsNothing);
      expect(find.childrenWithIcon(const Key('chat-4'), Icons.check), findsNothing);
      expect(find.childrenWithText(const Key('chat-4'), 'You: '), findsNothing);
      expect(find.childrenWithText(const Key('chat-4'), 'MSG_5'), findsOneWidget);
      expect(find.childrenWithText(const Key('chat-4'), '1'), findsOneWidget);
      expect(tester.textByKey(const Key('chats_unread_text')), equals('7'));
    });

    testWidgets('read_message_test', (tester) async {
      when(
        dp.chatsApi.getChats(),
      ).thenAnswer((_) async => HttpResponse(ChatsResponse(data: [_chatDto0, _chatDto1, _chatDto2], message: null), Response(requestOptions: RequestOptions(), statusCode: 200)));
      await tester.pumpWidget(dp.inject(child: const App()));

      /// test
      ws.setIsConnected(true);
      await tester.pumpAndSettle();
      expect(find.childrenWithText(const Key('chat-0'), '2'), findsOneWidget);
      expect(tester.textByKey(const Key('chats_unread_text')), equals('6'));

      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: _chatDto0.id, senderId: _chatDto0.otherUser.id, isCurrentUser: false, messagesIds: [999]));
      await tester.pumpAndSettle();
      expect(find.childrenWithText(const Key('chat-0'), '1'), findsOneWidget);
      expect(tester.textByKey(const Key('chats_unread_text')), equals('5'));

      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: _chatDto0.id, senderId: _chatDto0.otherUser.id, isCurrentUser: false, messagesIds: [_chatDto0.lastMessage!.id]));
      await tester.pumpAndSettle();
      expect(find.childrenWithKey(const Key('chat-0'), const Key('chat_unread_count_text')), findsNothing);
      expect(find.childrenWithIcon(const Key('chat-0'), Icons.check_box), findsNothing);
      expect(find.childrenWithIcon(const Key('chat-0'), Icons.check), findsNothing);
      expect(tester.textByKey(const Key('chats_unread_text')), equals('4'));
    });

    testWidgets('read_current_user_message_test', (tester) async {
      when(
        dp.chatsApi.getChats(),
      ).thenAnswer((_) async => HttpResponse(ChatsResponse(data: [_chatDto0, _chatDto1, _chatDto2, _chatDto3], message: null), Response(requestOptions: RequestOptions(), statusCode: 200)));
      await tester.pumpWidget(dp.inject(child: const App()));

      /// test
      ws.setIsConnected(true);
      await tester.pumpAndSettle();
      expect(find.childrenWithText(const Key('chat-0'), '2'), findsOneWidget);
      expect(tester.textByKey(const Key('chats_unread_text')), equals('6'));

      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: _chatDto0.id, senderId: 0, isCurrentUser: true, messagesIds: [999]));
      await tester.pumpAndSettle();
      expect(find.childrenWithText(const Key('chat-0'), '2'), findsOneWidget);
      expect(tester.textByKey(const Key('chats_unread_text')), equals('6'));

      expect(find.childrenWithIcon(const Key('chat-2'), Icons.check), findsOneWidget);
      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: _chatDto2.id, senderId: 0, isCurrentUser: true, messagesIds: [999]));
      await tester.pumpAndSettle();
      expect(find.childrenWithIcon(const Key('chat-2'), Icons.check), findsOneWidget);
      expect(tester.textByKey(const Key('chats_unread_text')), equals('6'));

      ws.addReadMessagesUpdate(ReadMessagesUpdate(chatId: _chatDto2.id, senderId: 0, isCurrentUser: true, messagesIds: [_chatDto2.lastMessage!.id]));
      await tester.pumpAndSettle();
      expect(tester.textByKey(const Key('chats_unread_text')), equals('6'));
      expect(find.childrenWithIcon(const Key('chat-2'), Icons.check_box), findsOneWidget);
    });

    /// TODO remove message test
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
