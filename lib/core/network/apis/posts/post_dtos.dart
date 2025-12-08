import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

part 'post_dtos.g.dart';

@JsonSerializable()
class PostResponseDto {
  final PostDto? data;
  final String? message;

  PostResponseDto({required this.data, required this.message});

  factory PostResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PostResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostResponseDtoToJson(this);
}

@JsonSerializable()
class PostsResponseDto {
  final List<PostDto>? data;
  final String? message;

  PostsResponseDto({required this.data, required this.message});

  factory PostsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PostsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostsResponseDtoToJson(this);
}

@JsonSerializable()
class CreatePostRequestDto {
  final String content;
  final List<String> images;

  CreatePostRequestDto({required this.content, required this.images});

  factory CreatePostRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePostRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostRequestDtoToJson(this);
}

@JsonSerializable()
class PostDto {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String content;
  final List<String> images;
  @JsonKey(name: 'users_who_liked_ids')
  final List<String> usersWhoLikedIds;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'edited_at')
  final int? editedAt;
  final UserDto user;

  PostDto({
    required this.id,
    required this.userId,
    required this.content,
    required this.images,
    required this.usersWhoLikedIds,
    required this.createdAt,
    required this.editedAt,
    required this.user,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) => _$PostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostDtoToJson(this);
}
