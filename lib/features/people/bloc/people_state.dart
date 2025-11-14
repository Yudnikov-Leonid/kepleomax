import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/user.dart';

part 'people_state.freezed.dart';

abstract class PeopleState {}

@freezed
abstract class PeopleStateBase with _$PeopleStateBase implements PeopleState {
  const factory PeopleStateBase({required PeopleData data}) = _PeopleStateBase;

  factory PeopleStateBase.initial() => PeopleStateBase(data: PeopleData.initial());
}

@freezed
abstract class PeopleStateError with _$PeopleStateError implements PeopleState {
  const factory PeopleStateError({required String message}) = _PeopleStateError;
}

@freezed
abstract class PeopleData with _$PeopleData implements PeopleState {
  const factory PeopleData({
    required String searchText,
    required List<User> users,
    @Default(false) bool isLoading,
    @Default(false) bool isAllUsersLoaded
  }) = _PeopleData;

  factory PeopleData.initial() => PeopleData(searchText: '', users: []);
}
