import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/user.dart';

part 'post.freezed.dart';

@freezed
abstract class Post with _$Post {
  const factory Post({
    required User user,
    required String content,
    required int likesCount,
    required int createdAt,
    int? updatedAt,
  }) = _Post;
}
