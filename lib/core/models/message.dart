import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/user.dart';

part 'message.freezed.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    required User user,
    required String message,
    required int createdAt,
    required int? editedAt,
  }) = _Message;
}
