// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'users_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UsersCollection {

 Iterable<User> get users; bool? get allUsersLoaded;
/// Create a copy of UsersCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsersCollectionCopyWith<UsersCollection> get copyWith => _$UsersCollectionCopyWithImpl<UsersCollection>(this as UsersCollection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsersCollection&&const DeepCollectionEquality().equals(other.users, users)&&(identical(other.allUsersLoaded, allUsersLoaded) || other.allUsersLoaded == allUsersLoaded));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(users),allUsersLoaded);

@override
String toString() {
  return 'UsersCollection(users: $users, allUsersLoaded: $allUsersLoaded)';
}


}

/// @nodoc
abstract mixin class $UsersCollectionCopyWith<$Res>  {
  factory $UsersCollectionCopyWith(UsersCollection value, $Res Function(UsersCollection) _then) = _$UsersCollectionCopyWithImpl;
@useResult
$Res call({
 Iterable<User> users, bool? allUsersLoaded
});




}
/// @nodoc
class _$UsersCollectionCopyWithImpl<$Res>
    implements $UsersCollectionCopyWith<$Res> {
  _$UsersCollectionCopyWithImpl(this._self, this._then);

  final UsersCollection _self;
  final $Res Function(UsersCollection) _then;

/// Create a copy of UsersCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? users = null,Object? allUsersLoaded = freezed,}) {
  return _then(_self.copyWith(
users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as Iterable<User>,allUsersLoaded: freezed == allUsersLoaded ? _self.allUsersLoaded : allUsersLoaded // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UsersCollection].
extension UsersCollectionPatterns on UsersCollection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UsersCollection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UsersCollection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UsersCollection value)  $default,){
final _that = this;
switch (_that) {
case _UsersCollection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UsersCollection value)?  $default,){
final _that = this;
switch (_that) {
case _UsersCollection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Iterable<User> users,  bool? allUsersLoaded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UsersCollection() when $default != null:
return $default(_that.users,_that.allUsersLoaded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Iterable<User> users,  bool? allUsersLoaded)  $default,) {final _that = this;
switch (_that) {
case _UsersCollection():
return $default(_that.users,_that.allUsersLoaded);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Iterable<User> users,  bool? allUsersLoaded)?  $default,) {final _that = this;
switch (_that) {
case _UsersCollection() when $default != null:
return $default(_that.users,_that.allUsersLoaded);case _:
  return null;

}
}

}

/// @nodoc


class _UsersCollection implements UsersCollection {
  const _UsersCollection({required this.users, this.allUsersLoaded});
  

@override final  Iterable<User> users;
@override final  bool? allUsersLoaded;

/// Create a copy of UsersCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsersCollectionCopyWith<_UsersCollection> get copyWith => __$UsersCollectionCopyWithImpl<_UsersCollection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsersCollection&&const DeepCollectionEquality().equals(other.users, users)&&(identical(other.allUsersLoaded, allUsersLoaded) || other.allUsersLoaded == allUsersLoaded));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(users),allUsersLoaded);

@override
String toString() {
  return 'UsersCollection(users: $users, allUsersLoaded: $allUsersLoaded)';
}


}

/// @nodoc
abstract mixin class _$UsersCollectionCopyWith<$Res> implements $UsersCollectionCopyWith<$Res> {
  factory _$UsersCollectionCopyWith(_UsersCollection value, $Res Function(_UsersCollection) _then) = __$UsersCollectionCopyWithImpl;
@override @useResult
$Res call({
 Iterable<User> users, bool? allUsersLoaded
});




}
/// @nodoc
class __$UsersCollectionCopyWithImpl<$Res>
    implements _$UsersCollectionCopyWith<$Res> {
  __$UsersCollectionCopyWithImpl(this._self, this._then);

  final _UsersCollection _self;
  final $Res Function(_UsersCollection) _then;

/// Create a copy of UsersCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? users = null,Object? allUsersLoaded = freezed,}) {
  return _then(_UsersCollection(
users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as Iterable<User>,allUsersLoaded: freezed == allUsersLoaded ? _self.allUsersLoaded : allUsersLoaded // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
