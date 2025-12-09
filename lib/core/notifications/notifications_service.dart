import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kepleomax/core/app.dart';
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
      'Base notifications channel',
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
      const InitializationSettings(android: initializationSettingsAndroid),
      onDidReceiveNotificationResponse: (response) {
        _handleAppOpened(response);
      },
    );
  }

  Future<void> init() async {
    await _messaging.requestPermission();

    await setupFlutterNotifications();

    FirebaseMessaging.onMessage.listen(showNotification);

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    final notificationAppLaunchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      if (notificationAppLaunchDetails!.notificationResponse != null) {
        _handleAppOpened(notificationAppLaunchDetails.notificationResponse!);
      }
    }
  }

  void _handleAppOpened(NotificationResponse response) {
    if (response.payload == null) return;
    final chatId = int.parse(response.payload!);

    (mainNavigatorGlobalKey.currentState as AppNavigatorState).push(
      ChatPage(chatId: chatId, otherUser: null),
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
        .map<int>((n) => int.parse(n.toString()))
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
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Base notifications channel',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: chatId,
      );
    } else if (type == 'cancel') {
      for (final id in messageIds) {
        _localNotifications.cancel(id);
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}
