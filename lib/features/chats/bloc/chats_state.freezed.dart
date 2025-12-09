// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chats_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatsStateBase {

 ChatsData get data;
/// Create a copy of ChatsStateBase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatsStateBaseCopyWith<ChatsStateBase> get copyWith => _$ChatsStateBaseCopyWithImpl<ChatsStateBase>(this as ChatsStateBase, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatsStateBase&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'ChatsStateBase(data: $data)';
}


}

/// @nodoc
abstract mixin class $ChatsStateBaseCopyWith<$Res>  {
  factory $ChatsStateBaseCopyWith(ChatsStateBase value, $Res Function(ChatsStateBase) _then) = _$ChatsStateBaseCopyWithImpl;
@useResult
$Res call({
 ChatsData data
});


$ChatsDataCopyWith<$Res> get data;

}
/// @nodoc
class _$ChatsStateBaseCopyWithImpl<$Res>
    implements $ChatsStateBaseCopyWith<$Res> {
  _$ChatsStateBaseCopyWithImpl(this._self, this._then);

  final ChatsStateBase _self;
  final $Res Function(ChatsStateBase) _then;

/// Create a copy of ChatsStateBase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ChatsData,
  ));
}
/// Create a copy of ChatsStateBase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatsDataCopyWith<$Res> get data {
  
  return $ChatsDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatsStateBase].
extension ChatsStateBasePatterns on ChatsStateBase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatsStateBase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatsStateBase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatsStateBase value)  $default,){
final _that = this;
switch (_that) {
case _ChatsStateBase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatsStateBase value)?  $default,){
final _that = this;
switch (_that) {
case _ChatsStateBase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatsData data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatsStateBase() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatsData data)  $default,) {final _that = this;
switch (_that) {
case _ChatsStateBase():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatsData data)?  $default,) {final _that = this;
switch (_that) {
case _ChatsStateBase() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _ChatsStateBase implements ChatsStateBase {
  const _ChatsStateBase({required this.data});
  

@override final  ChatsData data;

/// Create a copy of ChatsStateBase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatsStateBaseCopyWith<_ChatsStateBase> get copyWith => __$ChatsStateBaseCopyWithImpl<_ChatsStateBase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatsStateBase&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'ChatsStateBase(data: $data)';
}


}

/// @nodoc
abstract mixin class _$ChatsStateBaseCopyWith<$Res> implements $ChatsStateBaseCopyWith<$Res> {
  factory _$ChatsStateBaseCopyWith(_ChatsStateBase value, $Res Function(_ChatsStateBase) _then) = __$ChatsStateBaseCopyWithImpl;
@override @useResult
$Res call({
 ChatsData data
});


@override $ChatsDataCopyWith<$Res> get data;

}
/// @nodoc
class __$ChatsStateBaseCopyWithImpl<$Res>
    implements _$ChatsStateBaseCopyWith<$Res> {
  __$ChatsStateBaseCopyWithImpl(this._self, this._then);

  final _ChatsStateBase _self;
  final $Res Function(_ChatsStateBase) _then;

/// Create a copy of ChatsStateBase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_ChatsStateBase(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ChatsData,
  ));
}

/// Create a copy of ChatsStateBase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatsDataCopyWith<$Res> get data {
  
  return $ChatsDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
mixin _$ChatsStateMessage {

 String get message; bool get isError;
/// Create a copy of ChatsStateMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatsStateMessageCopyWith<ChatsStateMessage> get copyWith => _$ChatsStateMessageCopyWithImpl<ChatsStateMessage>(this as ChatsStateMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatsStateMessage&&(identical(other.message, message) || other.message == message)&&(identical(other.isError, isError) || other.isError == isError));
}


@override
int get hashCode => Object.hash(runtimeType,message,isError);

@override
String toString() {
  return 'ChatsStateMessage(message: $message, isError: $isError)';
}


}

/// @nodoc
abstract mixin class $ChatsStateMessageCopyWith<$Res>  {
  factory $ChatsStateMessageCopyWith(ChatsStateMessage value, $Res Function(ChatsStateMessage) _then) = _$ChatsStateMessageCopyWithImpl;
@useResult
$Res call({
 String message, bool isError
});




}
/// @nodoc
class _$ChatsStateMessageCopyWithImpl<$Res>
    implements $ChatsStateMessageCopyWith<$Res> {
  _$ChatsStateMessageCopyWithImpl(this._self, this._then);

  final ChatsStateMessage _self;
  final $Res Function(ChatsStateMessage) _then;

/// Create a copy of ChatsStateMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? isError = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatsStateMessage].
extension ChatsStateMessagePatterns on ChatsStateMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatsStateMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatsStateMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatsStateMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatsStateMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatsStateMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatsStateMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  bool isError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatsStateMessage() when $default != null:
return $default(_that.message,_that.isError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  bool isError)  $default,) {final _that = this;
switch (_that) {
case _ChatsStateMessage():
return $default(_that.message,_that.isError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  bool isError)?  $default,) {final _that = this;
switch (_that) {
case _ChatsStateMessage() when $default != null:
return $default(_that.message,_that.isError);case _:
  return null;

}
}

}

/// @nodoc


class _ChatsStateMessage implements ChatsStateMessage {
  const _ChatsStateMessage({required this.message, this.isError = false});
  

@override final  String message;
@override@JsonKey() final  bool isError;

/// Create a copy of ChatsStateMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatsStateMessageCopyWith<_ChatsStateMessage> get copyWith => __$ChatsStateMessageCopyWithImpl<_ChatsStateMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatsStateMessage&&(identical(other.message, message) || other.message == message)&&(identical(other.isError, isError) || other.isError == isError));
}


@override
int get hashCode => Object.hash(runtimeType,message,isError);

@override
String toString() {
  return 'ChatsStateMessage(message: $message, isError: $isError)';
}


}

/// @nodoc
abstract mixin class _$ChatsStateMessageCopyWith<$Res> implements $ChatsStateMessageCopyWith<$Res> {
  factory _$ChatsStateMessageCopyWith(_ChatsStateMessage value, $Res Function(_ChatsStateMessage) _then) = __$ChatsStateMessageCopyWithImpl;
@override @useResult
$Res call({
 String message, bool isError
});




}
/// @nodoc
class __$ChatsStateMessageCopyWithImpl<$Res>
    implements _$ChatsStateMessageCopyWith<$Res> {
  __$ChatsStateMessageCopyWithImpl(this._self, this._then);

  final _ChatsStateMessage _self;
  final $Res Function(_ChatsStateMessage) _then;

/// Create a copy of ChatsStateMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? isError = null,}) {
  return _then(_ChatsStateMessage(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ChatsStateError {

 String get message;
/// Create a copy of ChatsStateError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatsStateErrorCopyWith<ChatsStateError> get copyWith => _$ChatsStateErrorCopyWithImpl<ChatsStateError>(this as ChatsStateError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatsStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatsStateError(message: $message)';
}


}

/// @nodoc
abstract mixin class $ChatsStateErrorCopyWith<$Res>  {
  factory $ChatsStateErrorCopyWith(ChatsStateError value, $Res Function(ChatsStateError) _then) = _$ChatsStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ChatsStateErrorCopyWithImpl<$Res>
    implements $ChatsStateErrorCopyWith<$Res> {
  _$ChatsStateErrorCopyWithImpl(this._self, this._then);

  final ChatsStateError _self;
  final $Res Function(ChatsStateError) _then;

/// Create a copy of ChatsStateError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatsStateError].
extension ChatsStateErrorPatterns on ChatsStateError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatsStateError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatsStateError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatsStateError value)  $default,){
final _that = this;
switch (_that) {
case _ChatsStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatsStateError value)?  $default,){
final _that = this;
switch (_that) {
case _ChatsStateError() when $default != null:
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
case _ChatsStateError() when $default != null:
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
case _ChatsStateError():
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
case _ChatsStateError() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ChatsStateError implements ChatsStateError {
  const _ChatsStateError({required this.message});
  

@override final  String message;

/// Create a copy of ChatsStateError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatsStateErrorCopyWith<_ChatsStateError> get copyWith => __$ChatsStateErrorCopyWithImpl<_ChatsStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatsStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatsStateError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ChatsStateErrorCopyWith<$Res> implements $ChatsStateErrorCopyWith<$Res> {
  factory _$ChatsStateErrorCopyWith(_ChatsStateError value, $Res Function(_ChatsStateError) _then) = __$ChatsStateErrorCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ChatsStateErrorCopyWithImpl<$Res>
    implements _$ChatsStateErrorCopyWith<$Res> {
  __$ChatsStateErrorCopyWithImpl(this._self, this._then);

  final _ChatsStateError _self;
  final $Res Function(_ChatsStateError) _then;

/// Create a copy of ChatsStateError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ChatsStateError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ChatsData {

 List<Chat> get chats; int get totalUnreadCount; bool get isLoading;
/// Create a copy of ChatsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatsDataCopyWith<ChatsData> get copyWith => _$ChatsDataCopyWithImpl<ChatsData>(this as ChatsData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatsData&&const DeepCollectionEquality().equals(other.chats, chats)&&(identical(other.totalUnreadCount, totalUnreadCount) || other.totalUnreadCount == totalUnreadCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(chats),totalUnreadCount,isLoading);

@override
String toString() {
  return 'ChatsData(chats: $chats, totalUnreadCount: $totalUnreadCount, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $ChatsDataCopyWith<$Res>  {
  factory $ChatsDataCopyWith(ChatsData value, $Res Function(ChatsData) _then) = _$ChatsDataCopyWithImpl;
@useResult
$Res call({
 List<Chat> chats, int totalUnreadCount, bool isLoading
});




}
/// @nodoc
class _$ChatsDataCopyWithImpl<$Res>
    implements $ChatsDataCopyWith<$Res> {
  _$ChatsDataCopyWithImpl(this._self, this._then);

  final ChatsData _self;
  final $Res Function(ChatsData) _then;

/// Create a copy of ChatsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chats = null,Object? totalUnreadCount = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
chats: null == chats ? _self.chats : chats // ignore: cast_nullable_to_non_nullable
as List<Chat>,totalUnreadCount: null == totalUnreadCount ? _self.totalUnreadCount : totalUnreadCount // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatsData].
extension ChatsDataPatterns on ChatsData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatsData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatsData value)  $default,){
final _that = this;
switch (_that) {
case _ChatsData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatsData value)?  $default,){
final _that = this;
switch (_that) {
case _ChatsData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Chat> chats,  int totalUnreadCount,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatsData() when $default != null:
return $default(_that.chats,_that.totalUnreadCount,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Chat> chats,  int totalUnreadCount,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _ChatsData():
return $default(_that.chats,_that.totalUnreadCount,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Chat> chats,  int totalUnreadCount,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _ChatsData() when $default != null:
return $default(_that.chats,_that.totalUnreadCount,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _ChatsData implements ChatsData {
  const _ChatsData({required final  List<Chat> chats, required this.totalUnreadCount, this.isLoading = true}): _chats = chats;
  

 final  List<Chat> _chats;
@override List<Chat> get chats {
  if (_chats is EqualUnmodifiableListView) return _chats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chats);
}

@override final  int totalUnreadCount;
@override@JsonKey() final  bool isLoading;

/// Create a copy of ChatsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatsDataCopyWith<_ChatsData> get copyWith => __$ChatsDataCopyWithImpl<_ChatsData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatsData&&const DeepCollectionEquality().equals(other._chats, _chats)&&(identical(other.totalUnreadCount, totalUnreadCount) || other.totalUnreadCount == totalUnreadCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_chats),totalUnreadCount,isLoading);

@override
String toString() {
  return 'ChatsData(chats: $chats, totalUnreadCount: $totalUnreadCount, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$ChatsDataCopyWith<$Res> implements $ChatsDataCopyWith<$Res> {
  factory _$ChatsDataCopyWith(_ChatsData value, $Res Function(_ChatsData) _then) = __$ChatsDataCopyWithImpl;
@override @useResult
$Res call({
 List<Chat> chats, int totalUnreadCount, bool isLoading
});




}
/// @nodoc
class __$ChatsDataCopyWithImpl<$Res>
    implements _$ChatsDataCopyWith<$Res> {
  __$ChatsDataCopyWithImpl(this._self, this._then);

  final _ChatsData _self;
  final $Res Function(_ChatsData) _then;

/// Create a copy of ChatsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chats = null,Object? totalUnreadCount = null,Object? isLoading = null,}) {
  return _then(_ChatsData(
chats: null == chats ? _self._chats : chats // ignore: cast_nullable_to_non_nullable
as List<Chat>,totalUnreadCount: null == totalUnreadCount ? _self.totalUnreadCount : totalUnreadCount // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
