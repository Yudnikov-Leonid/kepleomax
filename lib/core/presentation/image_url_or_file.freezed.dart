// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_url_or_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImageUrlOrFile {

 String? get url; File? get file;
/// Create a copy of ImageUrlOrFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageUrlOrFileCopyWith<ImageUrlOrFile> get copyWith => _$ImageUrlOrFileCopyWithImpl<ImageUrlOrFile>(this as ImageUrlOrFile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageUrlOrFile&&(identical(other.url, url) || other.url == url)&&(identical(other.file, file) || other.file == file));
}


@override
int get hashCode => Object.hash(runtimeType,url,file);

@override
String toString() {
  return 'ImageUrlOrFile(url: $url, file: $file)';
}


}

/// @nodoc
abstract mixin class $ImageUrlOrFileCopyWith<$Res>  {
  factory $ImageUrlOrFileCopyWith(ImageUrlOrFile value, $Res Function(ImageUrlOrFile) _then) = _$ImageUrlOrFileCopyWithImpl;
@useResult
$Res call({
 String? url, File? file
});




}
/// @nodoc
class _$ImageUrlOrFileCopyWithImpl<$Res>
    implements $ImageUrlOrFileCopyWith<$Res> {
  _$ImageUrlOrFileCopyWithImpl(this._self, this._then);

  final ImageUrlOrFile _self;
  final $Res Function(ImageUrlOrFile) _then;

/// Create a copy of ImageUrlOrFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = freezed,Object? file = freezed,}) {
  return _then(_self.copyWith(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as File?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageUrlOrFile].
extension ImageUrlOrFilePatterns on ImageUrlOrFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageUrlOrFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageUrlOrFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageUrlOrFile value)  $default,){
final _that = this;
switch (_that) {
case _ImageUrlOrFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageUrlOrFile value)?  $default,){
final _that = this;
switch (_that) {
case _ImageUrlOrFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? url,  File? file)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageUrlOrFile() when $default != null:
return $default(_that.url,_that.file);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? url,  File? file)  $default,) {final _that = this;
switch (_that) {
case _ImageUrlOrFile():
return $default(_that.url,_that.file);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? url,  File? file)?  $default,) {final _that = this;
switch (_that) {
case _ImageUrlOrFile() when $default != null:
return $default(_that.url,_that.file);case _:
  return null;

}
}

}

/// @nodoc


class _ImageUrlOrFile implements ImageUrlOrFile {
  const _ImageUrlOrFile({this.url, this.file}): assert(url != null || file != null, 'Both fields cannot be null');
  

@override final  String? url;
@override final  File? file;

/// Create a copy of ImageUrlOrFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageUrlOrFileCopyWith<_ImageUrlOrFile> get copyWith => __$ImageUrlOrFileCopyWithImpl<_ImageUrlOrFile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageUrlOrFile&&(identical(other.url, url) || other.url == url)&&(identical(other.file, file) || other.file == file));
}


@override
int get hashCode => Object.hash(runtimeType,url,file);

@override
String toString() {
  return 'ImageUrlOrFile(url: $url, file: $file)';
}


}

/// @nodoc
abstract mixin class _$ImageUrlOrFileCopyWith<$Res> implements $ImageUrlOrFileCopyWith<$Res> {
  factory _$ImageUrlOrFileCopyWith(_ImageUrlOrFile value, $Res Function(_ImageUrlOrFile) _then) = __$ImageUrlOrFileCopyWithImpl;
@override @useResult
$Res call({
 String? url, File? file
});




}
/// @nodoc
class __$ImageUrlOrFileCopyWithImpl<$Res>
    implements _$ImageUrlOrFileCopyWith<$Res> {
  __$ImageUrlOrFileCopyWithImpl(this._self, this._then);

  final _ImageUrlOrFile _self;
  final $Res Function(_ImageUrlOrFile) _then;

/// Create a copy of ImageUrlOrFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = freezed,Object? file = freezed,}) {
  return _then(_ImageUrlOrFile(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as File?,
  ));
}


}

// dart format on
