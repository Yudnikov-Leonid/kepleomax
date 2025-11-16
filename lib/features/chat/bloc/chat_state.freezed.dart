// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatStateBase {

 ChatData get data;
/// Create a copy of ChatStateBase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStateBaseCopyWith<ChatStateBase> get copyWith => _$ChatStateBaseCopyWithImpl<ChatStateBase>(this as ChatStateBase, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatStateBase&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'ChatStateBase(data: $data)';
}


}

/// @nodoc
abstract mixin class $ChatStateBaseCopyWith<$Res>  {
  factory $ChatStateBaseCopyWith(ChatStateBase value, $Res Function(ChatStateBase) _then) = _$ChatStateBaseCopyWithImpl;
@useResult
$Res call({
 ChatData data
});


$ChatDataCopyWith<$Res> get data;

}
/// @nodoc
class _$ChatStateBaseCopyWithImpl<$Res>
    implements $ChatStateBaseCopyWith<$Res> {
  _$ChatStateBaseCopyWithImpl(this._self, this._then);

  final ChatStateBase _self;
  final $Res Function(ChatStateBase) _then;

/// Create a copy of ChatStateBase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ChatData,
  ));
}
/// Create a copy of ChatStateBase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatDataCopyWith<$Res> get data {
  
  return $ChatDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatStateBase].
extension ChatStateBasePatterns on ChatStateBase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatStateBase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatStateBase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatStateBase value)  $default,){
final _that = this;
switch (_that) {
case _ChatStateBase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatStateBase value)?  $default,){
final _that = this;
switch (_that) {
case _ChatStateBase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatData data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatStateBase() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatData data)  $default,) {final _that = this;
switch (_that) {
case _ChatStateBase():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatData data)?  $default,) {final _that = this;
switch (_that) {
case _ChatStateBase() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _ChatStateBase implements ChatStateBase {
  const _ChatStateBase({required this.data});
  

@override final  ChatData data;

/// Create a copy of ChatStateBase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatStateBaseCopyWith<_ChatStateBase> get copyWith => __$ChatStateBaseCopyWithImpl<_ChatStateBase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatStateBase&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'ChatStateBase(data: $data)';
}


}

/// @nodoc
abstract mixin class _$ChatStateBaseCopyWith<$Res> implements $ChatStateBaseCopyWith<$Res> {
  factory _$ChatStateBaseCopyWith(_ChatStateBase value, $Res Function(_ChatStateBase) _then) = __$ChatStateBaseCopyWithImpl;
@override @useResult
$Res call({
 ChatData data
});


@override $ChatDataCopyWith<$Res> get data;

}
/// @nodoc
class __$ChatStateBaseCopyWithImpl<$Res>
    implements _$ChatStateBaseCopyWith<$Res> {
  __$ChatStateBaseCopyWithImpl(this._self, this._then);

  final _ChatStateBase _self;
  final $Res Function(_ChatStateBase) _then;

/// Create a copy of ChatStateBase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_ChatStateBase(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ChatData,
  ));
}

/// Create a copy of ChatStateBase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatDataCopyWith<$Res> get data {
  
  return $ChatDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
mixin _$ChatStateError {

 String get message;
/// Create a copy of ChatStateError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStateErrorCopyWith<ChatStateError> get copyWith => _$ChatStateErrorCopyWithImpl<ChatStateError>(this as ChatStateError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatStateError(message: $message)';
}


}

/// @nodoc
abstract mixin class $ChatStateErrorCopyWith<$Res>  {
  factory $ChatStateErrorCopyWith(ChatStateError value, $Res Function(ChatStateError) _then) = _$ChatStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ChatStateErrorCopyWithImpl<$Res>
    implements $ChatStateErrorCopyWith<$Res> {
  _$ChatStateErrorCopyWithImpl(this._self, this._then);

  final ChatStateError _self;
  final $Res Function(ChatStateError) _then;

/// Create a copy of ChatStateError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatStateError].
extension ChatStateErrorPatterns on ChatStateError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatStateError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatStateError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatStateError value)  $default,){
final _that = this;
switch (_that) {
case _ChatStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatStateError value)?  $default,){
final _that = this;
switch (_that) {
case _ChatStateError() when $default != null:
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
case _ChatStateError() when $default != null:
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
case _ChatStateError():
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
case _ChatStateError() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ChatStateError implements ChatStateError {
  const _ChatStateError({required this.message});
  

@override final  String message;

/// Create a copy of ChatStateError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatStateErrorCopyWith<_ChatStateError> get copyWith => __$ChatStateErrorCopyWithImpl<_ChatStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChatStateError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ChatStateErrorCopyWith<$Res> implements $ChatStateErrorCopyWith<$Res> {
  factory _$ChatStateErrorCopyWith(_ChatStateError value, $Res Function(_ChatStateError) _then) = __$ChatStateErrorCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ChatStateErrorCopyWithImpl<$Res>
    implements _$ChatStateErrorCopyWith<$Res> {
  __$ChatStateErrorCopyWithImpl(this._self, this._then);

  final _ChatStateError _self;
  final $Res Function(_ChatStateError) _then;

/// Create a copy of ChatStateError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ChatStateError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ChatData {

 int get chatId; int get otherUserId; List<Message> get messages; bool get isLoading;
/// Create a copy of ChatData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatDataCopyWith<ChatData> get copyWith => _$ChatDataCopyWithImpl<ChatData>(this as ChatData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatData&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.otherUserId, otherUserId) || other.otherUserId == otherUserId)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,chatId,otherUserId,const DeepCollectionEquality().hash(messages),isLoading);

@override
String toString() {
  return 'ChatData(chatId: $chatId, otherUserId: $otherUserId, messages: $messages, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $ChatDataCopyWith<$Res>  {
  factory $ChatDataCopyWith(ChatData value, $Res Function(ChatData) _then) = _$ChatDataCopyWithImpl;
@useResult
$Res call({
 int chatId, int otherUserId, List<Message> messages, bool isLoading
});




}
/// @nodoc
class _$ChatDataCopyWithImpl<$Res>
    implements $ChatDataCopyWith<$Res> {
  _$ChatDataCopyWithImpl(this._self, this._then);

  final ChatData _self;
  final $Res Function(ChatData) _then;

/// Create a copy of ChatData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chatId = null,Object? otherUserId = null,Object? messages = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as int,otherUserId: null == otherUserId ? _self.otherUserId : otherUserId // ignore: cast_nullable_to_non_nullable
as int,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatData].
extension ChatDataPatterns on ChatData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatData value)  $default,){
final _that = this;
switch (_that) {
case _ChatData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatData value)?  $default,){
final _that = this;
switch (_that) {
case _ChatData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int chatId,  int otherUserId,  List<Message> messages,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatData() when $default != null:
return $default(_that.chatId,_that.otherUserId,_that.messages,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int chatId,  int otherUserId,  List<Message> messages,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _ChatData():
return $default(_that.chatId,_that.otherUserId,_that.messages,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int chatId,  int otherUserId,  List<Message> messages,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _ChatData() when $default != null:
return $default(_that.chatId,_that.otherUserId,_that.messages,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _ChatData implements ChatData {
  const _ChatData({required this.chatId, required this.otherUserId, required final  List<Message> messages, this.isLoading = false}): _messages = messages;
  

@override final  int chatId;
@override final  int otherUserId;
 final  List<Message> _messages;
@override List<Message> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  bool isLoading;

/// Create a copy of ChatData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatDataCopyWith<_ChatData> get copyWith => __$ChatDataCopyWithImpl<_ChatData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatData&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.otherUserId, otherUserId) || other.otherUserId == otherUserId)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,chatId,otherUserId,const DeepCollectionEquality().hash(_messages),isLoading);

@override
String toString() {
  return 'ChatData(chatId: $chatId, otherUserId: $otherUserId, messages: $messages, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$ChatDataCopyWith<$Res> implements $ChatDataCopyWith<$Res> {
  factory _$ChatDataCopyWith(_ChatData value, $Res Function(_ChatData) _then) = __$ChatDataCopyWithImpl;
@override @useResult
$Res call({
 int chatId, int otherUserId, List<Message> messages, bool isLoading
});




}
/// @nodoc
class __$ChatDataCopyWithImpl<$Res>
    implements _$ChatDataCopyWith<$Res> {
  __$ChatDataCopyWithImpl(this._self, this._then);

  final _ChatData _self;
  final $Res Function(_ChatData) _then;

/// Create a copy of ChatData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chatId = null,Object? otherUserId = null,Object? messages = null,Object? isLoading = null,}) {
  return _then(_ChatData(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as int,otherUserId: null == otherUserId ? _self.otherUserId : otherUserId // ignore: cast_nullable_to_non_nullable
as int,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
