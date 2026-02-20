import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

part 'post_dtos.g.dart';

@JsonSerializable()
class PostResponseDto {

  PostResponseDto({required this.data, required this.message});

  factory PostResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PostResponseDtoFromJson(json);
  final PostDto? data;
  final String? message;

  Map<String, dynamic> toJson() => _$PostResponseDtoToJson(this);
}

@JsonSerializable()
class PostsResponseDto {

  PostsResponseDto({required this.data, required this.message});

  factory PostsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PostsResponseDtoFromJson(json);
  final List<PostDto>? data;
  final String? message;

  Map<String, dynamic> toJson() => _$PostsResponseDtoToJson(this);
}

@JsonSerializable()
class CreatePostRequestDto {

  CreatePostRequestDto({required this.content, required this.images});

  factory CreatePostRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePostRequestDtoFromJson(json);
  final String content;
  final List<String> images;

  Map<String, dynamic> toJson() => _$CreatePostRequestDtoToJson(this);
}

@JsonSerializable()
class PostDto {

  PostDto({
    required this.id,
    required this.userId,
    required this.content,
    required this.images,
    required this.createdAt,
    required this.editedAt,
    required this.user,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) => _$PostDtoFromJson(json);
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String content;
  final List<String> images;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'edited_at')
  final int? editedAt;
  final UserDto user;

  Map<String, dynamic> toJson() => _$PostDtoToJson(this);
}
