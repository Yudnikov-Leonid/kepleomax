// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostListStateBase {

 List<Post> get posts;
/// Create a copy of PostListStateBase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostListStateBaseCopyWith<PostListStateBase> get copyWith => _$PostListStateBaseCopyWithImpl<PostListStateBase>(this as PostListStateBase, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostListStateBase&&const DeepCollectionEquality().equals(other.posts, posts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(posts));

@override
String toString() {
  return 'PostListStateBase(posts: $posts)';
}


}

/// @nodoc
abstract mixin class $PostListStateBaseCopyWith<$Res>  {
  factory $PostListStateBaseCopyWith(PostListStateBase value, $Res Function(PostListStateBase) _then) = _$PostListStateBaseCopyWithImpl;
@useResult
$Res call({
 List<Post> posts
});




}
/// @nodoc
class _$PostListStateBaseCopyWithImpl<$Res>
    implements $PostListStateBaseCopyWith<$Res> {
  _$PostListStateBaseCopyWithImpl(this._self, this._then);

  final PostListStateBase _self;
  final $Res Function(PostListStateBase) _then;

/// Create a copy of PostListStateBase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? posts = null,}) {
  return _then(_self.copyWith(
posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,
  ));
}

}


/// Adds pattern-matching-related methods to [PostListStateBase].
extension PostListStateBasePatterns on PostListStateBase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostListStateBase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostListStateBase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostListStateBase value)  $default,){
final _that = this;
switch (_that) {
case _PostListStateBase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostListStateBase value)?  $default,){
final _that = this;
switch (_that) {
case _PostListStateBase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Post> posts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostListStateBase() when $default != null:
return $default(_that.posts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Post> posts)  $default,) {final _that = this;
switch (_that) {
case _PostListStateBase():
return $default(_that.posts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Post> posts)?  $default,) {final _that = this;
switch (_that) {
case _PostListStateBase() when $default != null:
return $default(_that.posts);case _:
  return null;

}
}

}

/// @nodoc


class _PostListStateBase implements PostListStateBase {
  const _PostListStateBase({required final  List<Post> posts}): _posts = posts;
  

 final  List<Post> _posts;
@override List<Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}


/// Create a copy of PostListStateBase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostListStateBaseCopyWith<_PostListStateBase> get copyWith => __$PostListStateBaseCopyWithImpl<_PostListStateBase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostListStateBase&&const DeepCollectionEquality().equals(other._posts, _posts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_posts));

@override
String toString() {
  return 'PostListStateBase(posts: $posts)';
}


}

/// @nodoc
abstract mixin class _$PostListStateBaseCopyWith<$Res> implements $PostListStateBaseCopyWith<$Res> {
  factory _$PostListStateBaseCopyWith(_PostListStateBase value, $Res Function(_PostListStateBase) _then) = __$PostListStateBaseCopyWithImpl;
@override @useResult
$Res call({
 List<Post> posts
});




}
/// @nodoc
class __$PostListStateBaseCopyWithImpl<$Res>
    implements _$PostListStateBaseCopyWith<$Res> {
  __$PostListStateBaseCopyWithImpl(this._self, this._then);

  final _PostListStateBase _self;
  final $Res Function(_PostListStateBase) _then;

/// Create a copy of PostListStateBase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? posts = null,}) {
  return _then(_PostListStateBase(
posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,
  ));
}


}

/// @nodoc
mixin _$PostListStateError {

 String get message;
/// Create a copy of PostListStateError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostListStateErrorCopyWith<PostListStateError> get copyWith => _$PostListStateErrorCopyWithImpl<PostListStateError>(this as PostListStateError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostListStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PostListStateError(message: $message)';
}


}

/// @nodoc
abstract mixin class $PostListStateErrorCopyWith<$Res>  {
  factory $PostListStateErrorCopyWith(PostListStateError value, $Res Function(PostListStateError) _then) = _$PostListStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$PostListStateErrorCopyWithImpl<$Res>
    implements $PostListStateErrorCopyWith<$Res> {
  _$PostListStateErrorCopyWithImpl(this._self, this._then);

  final PostListStateError _self;
  final $Res Function(PostListStateError) _then;

/// Create a copy of PostListStateError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PostListStateError].
extension PostListStateErrorPatterns on PostListStateError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostListStateError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostListStateError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostListStateError value)  $default,){
final _that = this;
switch (_that) {
case _PostListStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostListStateError value)?  $default,){
final _that = this;
switch (_that) {
case _PostListStateError() when $default != null:
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
case _PostListStateError() when $default != null:
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
case _PostListStateError():
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
case _PostListStateError() when $default != null:
return $default(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _PostListStateError implements PostListStateError {
  const _PostListStateError({required this.message});
  

@override final  String message;

/// Create a copy of PostListStateError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostListStateErrorCopyWith<_PostListStateError> get copyWith => __$PostListStateErrorCopyWithImpl<_PostListStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostListStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PostListStateError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$PostListStateErrorCopyWith<$Res> implements $PostListStateErrorCopyWith<$Res> {
  factory _$PostListStateErrorCopyWith(_PostListStateError value, $Res Function(_PostListStateError) _then) = __$PostListStateErrorCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$PostListStateErrorCopyWithImpl<$Res>
    implements _$PostListStateErrorCopyWith<$Res> {
  __$PostListStateErrorCopyWithImpl(this._self, this._then);

  final _PostListStateError _self;
  final $Res Function(_PostListStateError) _then;

/// Create a copy of PostListStateError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_PostListStateError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$PostListStateLoading {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostListStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostListStateLoading()';
}


}

/// @nodoc
class $PostListStateLoadingCopyWith<$Res>  {
$PostListStateLoadingCopyWith(PostListStateLoading _, $Res Function(PostListStateLoading) __);
}


/// Adds pattern-matching-related methods to [PostListStateLoading].
extension PostListStateLoadingPatterns on PostListStateLoading {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostListStateLoading value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostListStateLoading() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostListStateLoading value)  $default,){
final _that = this;
switch (_that) {
case _PostListStateLoading():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostListStateLoading value)?  $default,){
final _that = this;
switch (_that) {
case _PostListStateLoading() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function()?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostListStateLoading() when $default != null:
return $default();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function()  $default,) {final _that = this;
switch (_that) {
case _PostListStateLoading():
return $default();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function()?  $default,) {final _that = this;
switch (_that) {
case _PostListStateLoading() when $default != null:
return $default();case _:
  return null;

}
}

}

/// @nodoc


class _PostListStateLoading implements PostListStateLoading {
  const _PostListStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostListStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PostListStateLoading()';
}


}




// dart format on
