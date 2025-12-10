// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostResponseDto _$PostResponseDtoFromJson(Map<String, dynamic> json) =>
    PostResponseDto(
      data: json['data'] == null
          ? null
          : PostDto.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$PostResponseDtoToJson(PostResponseDto instance) =>
    <String, dynamic>{'data': instance.data, 'message': instance.message};

PostsResponseDto _$PostsResponseDtoFromJson(Map<String, dynamic> json) =>
    PostsResponseDto(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => PostDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$PostsResponseDtoToJson(PostsResponseDto instance) =>
    <String, dynamic>{'data': instance.data, 'message': instance.message};

CreatePostRequestDto _$CreatePostRequestDtoFromJson(
  Map<String, dynamic> json,
) => CreatePostRequestDto(
  content: json['content'] as String,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$CreatePostRequestDtoToJson(
  CreatePostRequestDto instance,
) => <String, dynamic>{'content': instance.content, 'images': instance.images};

PostDto _$PostDtoFromJson(Map<String, dynamic> json) => PostDto(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  content: json['content'] as String,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: (json['created_at'] as num).toInt(),
  editedAt: (json['edited_at'] as num?)?.toInt(),
  user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PostDtoToJson(PostDto instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'content': instance.content,
  'images': instance.images,
  'created_at': instance.createdAt,
  'edited_at': instance.editedAt,
  'user': instance.user,
};
