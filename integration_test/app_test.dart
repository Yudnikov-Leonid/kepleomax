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
import 'package:kepleomax/features/chats/chats_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:retrofit/dio.dart';

import 'utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('chats_screen', () {
    late Dependencies dp;

    setUpAll(() {
      Flavor.setFlavor(Flavor.testing());
    });

    setUp(() async {
      dp = await initializeDependencies(useMocks: true);
      dp.authController.setUser(User.testing());
    });

    testWidgets('connection_test', (tester) async {
      when(dp.chatsApi.getChats()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 300));
        return HttpResponse(ChatsResponse(data: [], message: null), Response(requestOptions: RequestOptions(), statusCode: 200));
      });

      /// test (connect, disconnect)
      await tester.pumpWidget(dp.inject(child: const App()));
      expect(tester.textByKey(const Key('app_bar_text')), equals('Connecting..'));

      (dp.messagesWebSocket as MockMessagesWebSocket).setIsConnected(true);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.textByKey(const Key('app_bar_text')), equals('Updating..'));

      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(tester.textByKey(const Key('app_bar_text')), equals('Chats'));
      expect(find.byKey(const Key('find_people_button')), findsOneWidget);

      /// disconnect
      (dp.messagesWebSocket as MockMessagesWebSocket).setIsConnected(false);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.textByKey(const Key('app_bar_text')), equals('Connecting..'));

      (dp.messagesWebSocket as MockMessagesWebSocket).setIsConnected(true);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.textByKey(const Key('app_bar_text')), equals('Updating..'));

      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(tester.textByKey(const Key('app_bar_text')), equals('Chats'));
      expect(find.byKey(const Key('find_people_button')), findsOneWidget);
    });

    testWidgets('chats_statuses, unread_counter', (tester) async {
      when(
        dp.chatsApi.getChats(),
      ).thenAnswer((_) async => HttpResponse(ChatsResponse(data: [_chatDto0, _chatDto1, _chatDto2, _chatDto3, _chatDto4], message: null), Response(requestOptions: RequestOptions(), statusCode: 200)));

      /// test
      await tester.pumpWidget(dp.inject(child: const App()));
      (dp.messagesWebSocket as MockMessagesWebSocket).setIsConnected(true);
      await tester.pumpAndSettle(const Duration(seconds: 1));

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
  });
}

final _chatDto0 = const ChatDto(
  id: 0,
  otherUser: UserDto(id: 1, username: 'OTHER_USERNAME_1', profileImage: null, isCurrent: false),
  lastMessage: MessageDto(id: 0, chatId: 0, senderId: 1, isCurrentUser: false, message: 'MSG_0', isRead: false, createdAt: 1110, editedAt: null, fromCache: false),
  unreadCount: 2,
);

final _chatDto1 = const ChatDto(
  id: 1,
  otherUser: UserDto(id: 2, username: 'OTHER_USERNAME_2', profileImage: null, isCurrent: false),
  lastMessage: MessageDto(id: 1, chatId: 1, senderId: 2, isCurrentUser: false, message: 'MSG_1', isRead: false, createdAt: 1111, editedAt: null, fromCache: false),
  unreadCount: 4,
);

final _chatDto2 = const ChatDto(
  id: 2,
  otherUser: UserDto(id: 3, username: 'OTHER_USERNAME_3', profileImage: null, isCurrent: false),
  lastMessage: MessageDto(id: 2, chatId: 2, senderId: 0, isCurrentUser: true, message: 'MSG_2', isRead: false, createdAt: 1112, editedAt: null, fromCache: false),
  unreadCount: 0,
);

final _chatDto3 = const ChatDto(
  id: 3,
  otherUser: UserDto(id: 4, username: 'OTHER_USERNAME_4', profileImage: null, isCurrent: false),
  lastMessage: MessageDto(id: 3, chatId: 3, senderId: 0, isCurrentUser: true, message: 'MSG_3', isRead: true, createdAt: 1113, editedAt: null, fromCache: false),
  unreadCount: 0,
);

final _chatDto4 = const ChatDto(
  id: 4,
  otherUser: UserDto(id: 5, username: 'OTHER_USERNAME_5', profileImage: null, isCurrent: false),
  lastMessage: MessageDto(id: 4, chatId: 4, senderId: 5, isCurrentUser: false, message: 'MSG_4', isRead: true, createdAt: 1114, editedAt: null, fromCache: false),
  unreadCount: 0,
);
