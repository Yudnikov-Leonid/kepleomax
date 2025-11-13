// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostEditorStateBase {

 PostEditorData get data;
/// Create a copy of PostEditorStateBase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostEditorStateBaseCopyWith<PostEditorStateBase> get copyWith => _$PostEditorStateBaseCopyWithImpl<PostEditorStateBase>(this as PostEditorStateBase, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostEditorStateBase&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'PostEditorStateBase(data: $data)';
}


}

/// @nodoc
abstract mixin class $PostEditorStateBaseCopyWith<$Res>  {
  factory $PostEditorStateBaseCopyWith(PostEditorStateBase value, $Res Function(PostEditorStateBase) _then) = _$PostEditorStateBaseCopyWithImpl;
@useResult
$Res call({
 PostEditorData data
});


$PostEditorDataCopyWith<$Res> get data;

}
/// @nodoc
class _$PostEditorStateBaseCopyWithImpl<$Res>
    implements $PostEditorStateBaseCopyWith<$Res> {
  _$PostEditorStateBaseCopyWithImpl(this._self, this._then);

  final PostEditorStateBase _self;
  final $Res Function(PostEditorStateBase) _then;

/// Create a copy of PostEditorStateBase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PostEditorData,
  ));
}
/// Create a copy of PostEditorStateBase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostEditorDataCopyWith<$Res> get data {
  
  return $PostEditorDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostEditorStateBase].
extension PostEditorStateBasePatterns on PostEditorStateBase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostEditorStateBase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostEditorStateBase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostEditorStateBase value)  $default,){
final _that = this;
switch (_that) {
case _PostEditorStateBase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostEditorStateBase value)?  $default,){
final _that = this;
switch (_that) {
case _PostEditorStateBase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PostEditorData data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostEditorStateBase() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PostEditorData data)  $default,) {final _that = this;
switch (_that) {
case _PostEditorStateBase():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PostEditorData data)?  $default,) {final _that = this;
switch (_that) {
case _PostEditorStateBase() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _PostEditorStateBase implements PostEditorStateBase {
  const _PostEditorStateBase({required this.data});
  

@override final  PostEditorData data;

/// Create a copy of PostEditorStateBase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostEditorStateBaseCopyWith<_PostEditorStateBase> get copyWith => __$PostEditorStateBaseCopyWithImpl<_PostEditorStateBase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostEditorStateBase&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'PostEditorStateBase(data: $data)';
}


}

/// @nodoc
abstract mixin class _$PostEditorStateBaseCopyWith<$Res> implements $PostEditorStateBaseCopyWith<$Res> {
  factory _$PostEditorStateBaseCopyWith(_PostEditorStateBase value, $Res Function(_PostEditorStateBase) _then) = __$PostEditorStateBaseCopyWithImpl;
@override @useResult
$Res call({
 PostEditorData data
});


@override $PostEditorDataCopyWith<$Res> get data;

}
/// @nodoc
class __$PostEditorStateBaseCopyWithImpl<$Res>
    implements _$PostEditorStateBaseCopyWith<$Res> {
  __$PostEditorStateBaseCopyWithImpl(this._self, this._then);

  final _PostEditorStateBase _self;
  final $Res Function(_PostEditorStateBase) _then;

/// Create a copy of PostEditorStateBase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_PostEditorStateBase(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as PostEditorData,
  ));
}

/// Create a copy of PostEditorStateBase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostEditorDataCopyWith<$Res> get data {
  
  return $PostEditorDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc
mixin _$PostEditorStateError {

 String get message;
/// Create a copy of PostEditorStateError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostEditorStateErrorCopyWith<PostEditorStateError> get copyWith => _$PostEditorStateErrorCopyWithImpl<PostEditorStateError>(this as PostEditorStateError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostEditorStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PostEditorStateError(message: $message)';
}


}

/// @nodoc
abstract mixin class $PostEditorStateErrorCopyWith<$Res>  {
  factory $PostEditorStateErrorCopyWith(PostEditorStateError value, $Res Function(PostEditorStateError) _then) = _$PostEditorStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$PostEditorStateErrorCopyWithImpl<$Res>
    implements $PostEditorStateErrorCopyWith<$Res> {
  _$PostEditorStateErrorCopyWithImpl(this._self, this._then);

  final PostEditorStateError _self;
  final $Res Function(PostEditorStateError) _then;

/// Create a copy of PostEditorStateError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PostEditorStateError].
extension PostEditorStateErrorPatterns on PostEditorStateError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostEditorStateError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostEditorStateError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostEditorStateError value)  $default,){
final _that = this;
switch (_that) {
case _PostEditorStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostEditorStateError value)?  $default,){
final _that = this;
switch (_that) {
case _PostEditorStateError() when $default != null:
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
case _PostEditorStateError() when $default != null:
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
case _PostEditorStateError():
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
case _PostEditorStateError() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _PostEditorStateError implements PostEditorStateError {
  const _PostEditorStateError({required this.message});
  

@override final  String message;

/// Create a copy of PostEditorStateError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostEditorStateErrorCopyWith<_PostEditorStateError> get copyWith => __$PostEditorStateErrorCopyWithImpl<_PostEditorStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostEditorStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PostEditorStateError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$PostEditorStateErrorCopyWith<$Res> implements $PostEditorStateErrorCopyWith<$Res> {
  factory _$PostEditorStateErrorCopyWith(_PostEditorStateError value, $Res Function(_PostEditorStateError) _then) = __$PostEditorStateErrorCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$PostEditorStateErrorCopyWithImpl<$Res>
    implements _$PostEditorStateErrorCopyWith<$Res> {
  __$PostEditorStateErrorCopyWithImpl(this._self, this._then);

  final _PostEditorStateError _self;
  final $Res Function(_PostEditorStateError) _then;

/// Create a copy of PostEditorStateError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_PostEditorStateError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$PostEditorStateExit {

 bool get refreshPostsList;
/// Create a copy of PostEditorStateExit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostEditorStateExitCopyWith<PostEditorStateExit> get copyWith => _$PostEditorStateExitCopyWithImpl<PostEditorStateExit>(this as PostEditorStateExit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostEditorStateExit&&(identical(other.refreshPostsList, refreshPostsList) || other.refreshPostsList == refreshPostsList));
}


@override
int get hashCode => Object.hash(runtimeType,refreshPostsList);

@override
String toString() {
  return 'PostEditorStateExit(refreshPostsList: $refreshPostsList)';
}


}

/// @nodoc
abstract mixin class $PostEditorStateExitCopyWith<$Res>  {
  factory $PostEditorStateExitCopyWith(PostEditorStateExit value, $Res Function(PostEditorStateExit) _then) = _$PostEditorStateExitCopyWithImpl;
@useResult
$Res call({
 bool refreshPostsList
});




}
/// @nodoc
class _$PostEditorStateExitCopyWithImpl<$Res>
    implements $PostEditorStateExitCopyWith<$Res> {
  _$PostEditorStateExitCopyWithImpl(this._self, this._then);

  final PostEditorStateExit _self;
  final $Res Function(PostEditorStateExit) _then;

/// Create a copy of PostEditorStateExit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshPostsList = null,}) {
  return _then(_self.copyWith(
refreshPostsList: null == refreshPostsList ? _self.refreshPostsList : refreshPostsList // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PostEditorStateExit].
extension PostEditorStateExitPatterns on PostEditorStateExit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostEditorStateExit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostEditorStateExit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostEditorStateExit value)  $default,){
final _that = this;
switch (_that) {
case _PostEditorStateExit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostEditorStateExit value)?  $default,){
final _that = this;
switch (_that) {
case _PostEditorStateExit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool refreshPostsList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostEditorStateExit() when $default != null:
return $default(_that.refreshPostsList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool refreshPostsList)  $default,) {final _that = this;
switch (_that) {
case _PostEditorStateExit():
return $default(_that.refreshPostsList);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool refreshPostsList)?  $default,) {final _that = this;
switch (_that) {
case _PostEditorStateExit() when $default != null:
return $default(_that.refreshPostsList);case _:
  return null;

}
}

}

/// @nodoc


class _PostEditorStateExit implements PostEditorStateExit {
  const _PostEditorStateExit({required this.refreshPostsList});
  

@override final  bool refreshPostsList;

/// Create a copy of PostEditorStateExit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostEditorStateExitCopyWith<_PostEditorStateExit> get copyWith => __$PostEditorStateExitCopyWithImpl<_PostEditorStateExit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostEditorStateExit&&(identical(other.refreshPostsList, refreshPostsList) || other.refreshPostsList == refreshPostsList));
}


@override
int get hashCode => Object.hash(runtimeType,refreshPostsList);

@override
String toString() {
  return 'PostEditorStateExit(refreshPostsList: $refreshPostsList)';
}


}

/// @nodoc
abstract mixin class _$PostEditorStateExitCopyWith<$Res> implements $PostEditorStateExitCopyWith<$Res> {
  factory _$PostEditorStateExitCopyWith(_PostEditorStateExit value, $Res Function(_PostEditorStateExit) _then) = __$PostEditorStateExitCopyWithImpl;
@override @useResult
$Res call({
 bool refreshPostsList
});




}
/// @nodoc
class __$PostEditorStateExitCopyWithImpl<$Res>
    implements _$PostEditorStateExitCopyWith<$Res> {
  __$PostEditorStateExitCopyWithImpl(this._self, this._then);

  final _PostEditorStateExit _self;
  final $Res Function(_PostEditorStateExit) _then;

/// Create a copy of PostEditorStateExit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshPostsList = null,}) {
  return _then(_PostEditorStateExit(
refreshPostsList: null == refreshPostsList ? _self.refreshPostsList : refreshPostsList // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$PostEditorData {

 String get text; List<ImageUrlOrFile> get images; bool get isLoading;
/// Create a copy of PostEditorData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostEditorDataCopyWith<PostEditorData> get copyWith => _$PostEditorDataCopyWithImpl<PostEditorData>(this as PostEditorData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostEditorData&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(images),isLoading);

@override
String toString() {
  return 'PostEditorData(text: $text, images: $images, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $PostEditorDataCopyWith<$Res>  {
  factory $PostEditorDataCopyWith(PostEditorData value, $Res Function(PostEditorData) _then) = _$PostEditorDataCopyWithImpl;
@useResult
$Res call({
 String text, List<ImageUrlOrFile> images, bool isLoading
});




}
/// @nodoc
class _$PostEditorDataCopyWithImpl<$Res>
    implements $PostEditorDataCopyWith<$Res> {
  _$PostEditorDataCopyWithImpl(this._self, this._then);

  final PostEditorData _self;
  final $Res Function(PostEditorData) _then;

/// Create a copy of PostEditorData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? images = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ImageUrlOrFile>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PostEditorData].
extension PostEditorDataPatterns on PostEditorData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostEditorData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostEditorData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostEditorData value)  $default,){
final _that = this;
switch (_that) {
case _PostEditorData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostEditorData value)?  $default,){
final _that = this;
switch (_that) {
case _PostEditorData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  List<ImageUrlOrFile> images,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostEditorData() when $default != null:
return $default(_that.text,_that.images,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  List<ImageUrlOrFile> images,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _PostEditorData():
return $default(_that.text,_that.images,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  List<ImageUrlOrFile> images,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _PostEditorData() when $default != null:
return $default(_that.text,_that.images,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _PostEditorData extends PostEditorData {
  const _PostEditorData({required this.text, required final  List<ImageUrlOrFile> images, required this.isLoading}): _images = images,super._();
  

@override final  String text;
 final  List<ImageUrlOrFile> _images;
@override List<ImageUrlOrFile> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  bool isLoading;

/// Create a copy of PostEditorData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostEditorDataCopyWith<_PostEditorData> get copyWith => __$PostEditorDataCopyWithImpl<_PostEditorData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostEditorData&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_images),isLoading);

@override
String toString() {
  return 'PostEditorData(text: $text, images: $images, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$PostEditorDataCopyWith<$Res> implements $PostEditorDataCopyWith<$Res> {
  factory _$PostEditorDataCopyWith(_PostEditorData value, $Res Function(_PostEditorData) _then) = __$PostEditorDataCopyWithImpl;
@override @useResult
$Res call({
 String text, List<ImageUrlOrFile> images, bool isLoading
});




}
/// @nodoc
class __$PostEditorDataCopyWithImpl<$Res>
    implements _$PostEditorDataCopyWith<$Res> {
  __$PostEditorDataCopyWithImpl(this._self, this._then);

  final _PostEditorData _self;
  final $Res Function(_PostEditorData) _then;

/// Create a copy of PostEditorData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? images = null,Object? isLoading = null,}) {
  return _then(_PostEditorData(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ImageUrlOrFile>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
