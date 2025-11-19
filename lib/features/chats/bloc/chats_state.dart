import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/chat.dart';

part 'chats_state.freezed.dart';

abstract class ChatsState {}

@freezed
abstract class ChatsStateBase with _$ChatsStateBase implements ChatsState {
  const factory ChatsStateBase({required ChatsData data}) = _ChatsStateBase;

  factory ChatsStateBase.initial() => ChatsStateBase(data: ChatsData.initial());
}

@freezed
abstract class ChatsStateError with _$ChatsStateError implements ChatsState {
  const factory ChatsStateError({required String message}) = _ChatsStateError;
}

@freezed
abstract class ChatsData with _$ChatsData implements ChatsState {
  const factory ChatsData({
    required List<Chat> chats,
    required int totalUnreadCount,
    @Default(true) bool isLoading,
  }) = _ChatsData;

  factory ChatsData.initial() => ChatsData(chats: [], totalUnreadCount: 0);
}
