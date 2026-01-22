import 'package:kepleomax/core/models/chat.dart';

class ChatsCollection {
  final Iterable<Chat> chats;
  final bool fromCache;

  ChatsCollection({required this.chats, this.fromCache = false});
}
