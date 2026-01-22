import 'package:kepleomax/core/models/message.dart';

class MessagesCollection {
  final Iterable<Message> messages;

  /// if get messages from cache, loading still have to be visible
  final bool maintainLoading;
  final bool? allMessagesLoaded;

  MessagesCollection({
    required this.messages,
    this.maintainLoading = false,
    this.allMessagesLoaded,
  });
}
