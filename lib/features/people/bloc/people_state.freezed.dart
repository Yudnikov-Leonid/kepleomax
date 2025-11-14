// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'people_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PeopleStateBase {

 PeopleData get data;
/// Create a copy of PeopleStateBase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeopleStateBaseCopyWith<PeopleStateBase> get copyWith => _$PeopleStateBaseCopyWithImpl<PeopleStateBase>(this as PeopleStateBase, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeopleStateBase&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'PeopleStateBase(data: $data)';
}


}

/// @nodoc
abstract mixin class $PeopleStateBaseCopyWith<$Res>  {
  factory $PeopleStateBaseCopyWith(PeopleStateBase value, $Res Function(PeopleStateBase) _then) = _$PeopleStateBaseCopyWithImpl;
@useResult
$Res call({
 PeopleData data
});


$PeopleDataCopyWith<$Res> get data;

}
/// @nodoc
class _$PeopleStateBaseCopyWithImpl<$Res>
    implements $PeopleStateBaseCopyWith<$Res> {
  _$PeopleStateBaseCopyWithImpl(this._self, this._then);

  final PeopleStateBase _self;
  final $Res Function(PeopleStateBase) _then;

/// Create a copy of PeopleStateBase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PeopleData,
  ));
}
/// Create a copy of PeopleStateBase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeopleDataCopyWith<$Res> get data {
  
  return $PeopleDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [PeopleStateBase].
extension PeopleStateBasePatterns on PeopleStateBase {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeopleStateBase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeopleStateBase() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeopleStateBase value)  $default,){
final _that = this;
switch (_that) {
case _PeopleStateBase():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeopleStateBase value)?  $default,){
final _that = this;
switch (_that) {
case _PeopleStateBase() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PeopleData data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeopleStateBase() when $default != null:
return $default(_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PeopleData data)  $default,) {final _that = this;
switch (_that) {
case _PeopleStateBase():
return $default(_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PeopleData data)?  $default,) {final _that = this;
switch (_that) {
case _PeopleStateBase() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _PeopleStateBase implements PeopleStateBase {
  const _PeopleStateBase({required this.data});
  

@override final  PeopleData data;

/// Create a copy of PeopleStateBase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeopleStateBaseCopyWith<_PeopleStateBase> get copyWith => __$PeopleStateBaseCopyWithImpl<_PeopleStateBase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeopleStateBase&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'PeopleStateBase(data: $data)';
}


}

/// @nodoc
abstract mixin class _$PeopleStateBaseCopyWith<$Res> implements $PeopleStateBaseCopyWith<$Res> {
  factory _$PeopleStateBaseCopyWith(_PeopleStateBase value, $Res Function(_PeopleStateBase) _then) = __$PeopleStateBaseCopyWithImpl;
@override @useResult
$Res call({
 PeopleData data
});


@override $PeopleDataCopyWith<$Res> get data;

}
/// @nodoc
class __$PeopleStateBaseCopyWithImpl<$Res>
    implements _$PeopleStateBaseCopyWith<$Res> {
  __$PeopleStateBaseCopyWithImpl(this._self, this._then);

  final _PeopleStateBase _self;
  final $Res Function(_PeopleStateBase) _then;

/// Create a copy of PeopleStateBase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_PeopleStateBase(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PeopleData,
  ));
}

/// Create a copy of PeopleStateBase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeopleDataCopyWith<$Res> get data {
  
  return $PeopleDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
mixin _$PeopleStateError {

 String get message;
/// Create a copy of PeopleStateError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeopleStateErrorCopyWith<PeopleStateError> get copyWith => _$PeopleStateErrorCopyWithImpl<PeopleStateError>(this as PeopleStateError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeopleStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PeopleStateError(message: $message)';
}


}

/// @nodoc
abstract mixin class $PeopleStateErrorCopyWith<$Res>  {
  factory $PeopleStateErrorCopyWith(PeopleStateError value, $Res Function(PeopleStateError) _then) = _$PeopleStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$PeopleStateErrorCopyWithImpl<$Res>
    implements $PeopleStateErrorCopyWith<$Res> {
  _$PeopleStateErrorCopyWithImpl(this._self, this._then);

  final PeopleStateError _self;
  final $Res Function(PeopleStateError) _then;

/// Create a copy of PeopleStateError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PeopleStateError].
extension PeopleStateErrorPatterns on PeopleStateError {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeopleStateError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeopleStateError() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeopleStateError value)  $default,){
final _that = this;
switch (_that) {
case _PeopleStateError():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeopleStateError value)?  $default,){
final _that = this;
switch (_that) {
case _PeopleStateError() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeopleStateError() when $default != null:
return $default(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message)  $default,) {final _that = this;
switch (_that) {
case _PeopleStateError():
return $default(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message)?  $default,) {final _that = this;
switch (_that) {
case _PeopleStateError() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _PeopleStateError implements PeopleStateError {
  const _PeopleStateError({required this.message});
  

@override final  String message;

/// Create a copy of PeopleStateError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeopleStateErrorCopyWith<_PeopleStateError> get copyWith => __$PeopleStateErrorCopyWithImpl<_PeopleStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeopleStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PeopleStateError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$PeopleStateErrorCopyWith<$Res> implements $PeopleStateErrorCopyWith<$Res> {
  factory _$PeopleStateErrorCopyWith(_PeopleStateError value, $Res Function(_PeopleStateError) _then) = __$PeopleStateErrorCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$PeopleStateErrorCopyWithImpl<$Res>
    implements _$PeopleStateErrorCopyWith<$Res> {
  __$PeopleStateErrorCopyWithImpl(this._self, this._then);

  final _PeopleStateError _self;
  final $Res Function(_PeopleStateError) _then;

/// Create a copy of PeopleStateError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_PeopleStateError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$PeopleData {

 String get searchText; List<User> get users; bool get isLoading; bool get isAllUsersLoaded;
/// Create a copy of PeopleData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeopleDataCopyWith<PeopleData> get copyWith => _$PeopleDataCopyWithImpl<PeopleData>(this as PeopleData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeopleData&&(identical(other.searchText, searchText) || other.searchText == searchText)&&const DeepCollectionEquality().equals(other.users, users)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isAllUsersLoaded, isAllUsersLoaded) || other.isAllUsersLoaded == isAllUsersLoaded));
}


@override
int get hashCode => Object.hash(runtimeType,searchText,const DeepCollectionEquality().hash(users),isLoading,isAllUsersLoaded);

@override
String toString() {
  return 'PeopleData(searchText: $searchText, users: $users, isLoading: $isLoading, isAllUsersLoaded: $isAllUsersLoaded)';
}


}

/// @nodoc
abstract mixin class $PeopleDataCopyWith<$Res>  {
  factory $PeopleDataCopyWith(PeopleData value, $Res Function(PeopleData) _then) = _$PeopleDataCopyWithImpl;
@useResult
$Res call({
 String searchText, List<User> users, bool isLoading, bool isAllUsersLoaded
});




}
/// @nodoc
class _$PeopleDataCopyWithImpl<$Res>
    implements $PeopleDataCopyWith<$Res> {
  _$PeopleDataCopyWithImpl(this._self, this._then);

  final PeopleData _self;
  final $Res Function(PeopleData) _then;

/// Create a copy of PeopleData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchText = null,Object? users = null,Object? isLoading = null,Object? isAllUsersLoaded = null,}) {
  return _then(_self.copyWith(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<User>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isAllUsersLoaded: null == isAllUsersLoaded ? _self.isAllUsersLoaded : isAllUsersLoaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PeopleData].
extension PeopleDataPatterns on PeopleData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeopleData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeopleData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeopleData value)  $default,){
final _that = this;
switch (_that) {
case _PeopleData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeopleData value)?  $default,){
final _that = this;
switch (_that) {
case _PeopleData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchText,  List<User> users,  bool isLoading,  bool isAllUsersLoaded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeopleData() when $default != null:
return $default(_that.searchText,_that.users,_that.isLoading,_that.isAllUsersLoaded);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchText,  List<User> users,  bool isLoading,  bool isAllUsersLoaded)  $default,) {final _that = this;
switch (_that) {
case _PeopleData():
return $default(_that.searchText,_that.users,_that.isLoading,_that.isAllUsersLoaded);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchText,  List<User> users,  bool isLoading,  bool isAllUsersLoaded)?  $default,) {final _that = this;
switch (_that) {
case _PeopleData() when $default != null:
return $default(_that.searchText,_that.users,_that.isLoading,_that.isAllUsersLoaded);case _:
  return null;

}
}

}

/// @nodoc


class _PeopleData implements PeopleData {
  const _PeopleData({required this.searchText, required final  List<User> users, this.isLoading = false, this.isAllUsersLoaded = false}): _users = users;
  

@override final  String searchText;
 final  List<User> _users;
@override List<User> get users {
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_users);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isAllUsersLoaded;

/// Create a copy of PeopleData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeopleDataCopyWith<_PeopleData> get copyWith => __$PeopleDataCopyWithImpl<_PeopleData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeopleData&&(identical(other.searchText, searchText) || other.searchText == searchText)&&const DeepCollectionEquality().equals(other._users, _users)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isAllUsersLoaded, isAllUsersLoaded) || other.isAllUsersLoaded == isAllUsersLoaded));
}


@override
int get hashCode => Object.hash(runtimeType,searchText,const DeepCollectionEquality().hash(_users),isLoading,isAllUsersLoaded);

@override
String toString() {
  return 'PeopleData(searchText: $searchText, users: $users, isLoading: $isLoading, isAllUsersLoaded: $isAllUsersLoaded)';
}


}

/// @nodoc
abstract mixin class _$PeopleDataCopyWith<$Res> implements $PeopleDataCopyWith<$Res> {
  factory _$PeopleDataCopyWith(_PeopleData value, $Res Function(_PeopleData) _then) = __$PeopleDataCopyWithImpl;
@override @useResult
$Res call({
 String searchText, List<User> users, bool isLoading, bool isAllUsersLoaded
});




}
/// @nodoc
class __$PeopleDataCopyWithImpl<$Res>
    implements _$PeopleDataCopyWith<$Res> {
  __$PeopleDataCopyWithImpl(this._self, this._then);

  final _PeopleData _self;
  final $Res Function(_PeopleData) _then;

/// Create a copy of PeopleData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchText = null,Object? users = null,Object? isLoading = null,Object? isAllUsersLoaded = null,}) {
  return _then(_PeopleData(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,users: null == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<User>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isAllUsersLoaded: null == isAllUsersLoaded ? _self.isAllUsersLoaded : isAllUsersLoaded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
