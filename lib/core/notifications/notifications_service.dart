import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kepleomax/core/app.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/features/chats/chats_screen_navigator.dart';

class NotificationService {
  NotificationService._privateConstructor();

  static final NotificationService instance =
      NotificationService._privateConstructor();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> setupFlutterNotifications() async {
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High importance notifications',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    await _localNotifications.initialize(
      InitializationSettings(android: initializationSettingsAndroid),
      onDidReceiveNotificationResponse: (response) {
        print('MyLog OPEN APP: $response');
        (mainNavigatorGlobalKey.currentState!.widget as AppNavigatorState).push(
          ChatPage(
            chat: Chat(
              id: 1,
              otherUser: User.loading(),
              lastMessage: null,
              unreadCount: 0,
            ),
          ),
        );
      },
    );
  }

  Future<void> init() async {
    await _messaging.requestPermission();

    FirebaseMessaging.onMessage.listen(showNotification);

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    /// opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleAppOpened(initialMessage);
    }
  }

  void _handleAppOpened(RemoteMessage message) {
    print('MyLog OPEN APP: $message');

    (mainNavigatorGlobalKey.currentState!.widget as AppNavigatorState).push(
      ChatPage(
        chat: Chat(
          id: 1,
          otherUser: User.loading(),
          lastMessage: null,
          unreadCount: 0,
        ),
      ),
    );
  }

  int _openedChatId = -1;

  void blockNotificationsFromChat(int chatId) {
    _openedChatId = chatId;
  }

  void enableAllNotifications() {
    _openedChatId = -1;
  }

  void closeNotification(int id) {
    _localNotifications.cancel(id);
  }

  Future<void> showNotification(RemoteMessage message) async {
    List<int> messageIds = json
        .decode(message.data['ids'])
        .map<int>((e) => int.parse(e.toString()))
        .toList();
    if (messageIds.isEmpty) return;

    /// check type
    String? type = message.data['type'];
    if (type == null) return;
    if (type == 'new') {
      /// check chat_id
      String? chatId = message.data['chat_id'];
      if (chatId == null) return;
      if (_openedChatId != -1 && chatId == _openedChatId.toString()) return;

      await _localNotifications.show(
        messageIds[0],
        message.data['title'],
        message.data['body'],
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High importance notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: 'chatId: 54545',
      );
    } else if (type == 'cancel') {
      messageIds.forEach((id) {
        _localNotifications.cancel(id);
      });
    }
  }
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  print('FCM message: ${message.data}');
  await Firebase.initializeApp();
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}
