import 'dart:async';

import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:kepleomax/core/network/websockets/models/deleted_message_update.dart';
import 'package:kepleomax/core/network/websockets/models/new_message_update.dart';
import 'package:kepleomax/core/network/websockets/models/online_status_update.dart';
import 'package:kepleomax/core/network/websockets/models/read_messages_update.dart';
import 'package:kepleomax/core/network/websockets/models/typing_activity_update.dart';

class FakeMessagesWebSocket implements MessagesWebSocket {
  @override
  Future<void> init() async {}

  @override
  void reinit() {}

  @override
  void disconnect() {}

  @override
  void connectIfNot() {}

  @override
  void deleteMessage({required int messageId}) {}

  @override
  void sendMessage({required String message, required int recipientId}) {}

  @override
  void readAllMessages({required int chatId}) {}

  @override
  void readMessagesBeforeTime({required int chatId, required DateTime time}) {}

  @override
  void subscribeOnOnlineStatusUpdates({required Iterable<int> usersIds}) {}

  @override
  void activityDetected() {}

  @override
  void typingActivityDetected({required int chatId}) {}

  @override
  bool get isConnected => true;

  @override
  Stream<bool> get connectionStateStream =>
      StreamController<bool>.broadcast().stream;

  @override
  Stream<DeletedMessageUpdate> get deletedMessageStream =>
      StreamController<DeletedMessageUpdate>.broadcast().stream;

  @override
  Stream<NewMessageUpdate> get newMessageUpdatesStream =>
      StreamController<NewMessageUpdate>.broadcast().stream;

  @override
  Stream<OnlineStatusUpdate> get onlineUpdatesStream =>
      StreamController<OnlineStatusUpdate>.broadcast().stream;

  @override
  Stream<ReadMessagesUpdate> get readMessagesStream =>
      StreamController<ReadMessagesUpdate>.broadcast().stream;

  @override
  Stream<TypingActivityUpdate> get typingUpdatesStream =>
      StreamController<TypingActivityUpdate>.broadcast().stream;
}
