import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/user.dart';

part 'users_collection.freezed.dart';

@freezed
abstract class UsersCollection with _$UsersCollection {
  const factory UsersCollection({
    required Iterable<User> users,
    bool? allUsersLoaded,
  }) = _UsersCollection;
}
