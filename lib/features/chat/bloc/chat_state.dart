import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/message.dart';

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
abstract class ChatData with _$ChatData implements ChatState {
  const factory ChatData({
    required int chatId,
    required int otherUserId,
    required List<Message> messages,
    @Default(false) bool isLoading,
  }) = _ChatData;

  factory ChatData.initial() => ChatData(chatId: -1, otherUserId: -1, messages: []);
}
