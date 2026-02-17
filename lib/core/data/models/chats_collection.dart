import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/chat.dart';

part 'chats_collection.freezed.dart';

@freezed
abstract class ChatsCollection with _$ChatsCollection {
  const factory ChatsCollection({
    required Iterable<Chat> chats,
    @Default(false) bool fromCache,
  }) = _ChatsCollection;
}
