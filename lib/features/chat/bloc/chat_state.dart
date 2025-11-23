import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';

part 'chat_state.freezed.dart';

abstract class ChatState {}

@freezed
abstract class ChatStateBase with _$ChatStateBase implements ChatState {
  const factory ChatStateBase({required ChatData data}) = _ChatStateBase;

  factory ChatStateBase.initial() => ChatStateBase(data: ChatData.initial());
}

@freezed
abstract class ChatStateError with _$ChatStateError implements ChatState {
  const factory ChatStateError({required String message}) = _ChatStateError;
}

@freezed
abstract class ChatStateMessage with _$ChatStateMessage implements ChatState {
  const factory ChatStateMessage({required String message, required bool isError}) =
      _ChatStateMessage;
}

@freezed
abstract class ChatData with _$ChatData implements ChatState {
  const factory ChatData({
    required int chatId,
    /// if user in chat was null
    required User? otherUser,
    required List<Message> messages,
    required bool isAllMessagesLoaded,
    @Default(false) bool isLoading,
  }) = _ChatData;

  factory ChatData.initial() => const ChatData(
    chatId: -1,
    otherUser: null,
    messages: [],
    isAllMessagesLoaded: false,
  );
}
