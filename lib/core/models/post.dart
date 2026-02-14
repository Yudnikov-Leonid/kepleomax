import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/apis/posts/post_dtos.dart';

part 'post.freezed.dart';

@freezed
abstract class Post with _$Post {
  const factory Post({
    required int id,
    required User user,
    required String content,
    required List<String> images,
    required int likesCount,
    required DateTime createdAt,
    @Default(false) bool isMockLoadingPost,
    DateTime? updatedAt,
  }) = _Post;

  factory Post.fromDto(PostDto dto) => Post(
    id: dto.id,
    user: User.fromDto(dto.user),
    content: dto.content,
    images: dto.images,
    likesCount: 0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(dto.createdAt),
    updatedAt: dto.editedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(dto.editedAt!),
  );

  factory Post.loading() => Post(
    id: 0,
    user: User.loading(),
    content: '\n\n\n\n',
    images: [],
    likesCount: 999999,
    createdAt: DateTime(0),
    isMockLoadingPost: true,
  );
}
