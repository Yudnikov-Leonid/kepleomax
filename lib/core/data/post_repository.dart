import 'package:kepleomax/core/models/post.dart';
import 'package:kepleomax/core/network/apis/posts/post_api.dart';
import 'package:kepleomax/core/network/apis/posts/post_dtos.dart';

class PostRepository {
  final PostApi _postApi;

  PostRepository({required PostApi postApi}) : _postApi = postApi;

  Future<Post> updatePost({
    required int postId,
    required String content,
    required List<String> images,
  }) async {
    final res = await _postApi.updatePost(
        postId: postId, data: CreatePostRequestDto(content: content, images: images));

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to update the post: ${res.response.statusCode}",
      );
    }

    return Post.fromDto(res.data.data!);
  }

  Future<Post> deletePost({required int postId}) async {
    final res = await _postApi.deletePost(postId: postId);

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to delete the post: ${res.response.statusCode}",
      );
    }

    return Post.fromDto(res.data.data!);
  }

  Future<Post> createNewPost({
    required String content,
    required List<String> images,
  }) async {
    final res = await _postApi.createNewPost(
      data: CreatePostRequestDto(content: content, images: images),
    );

    if (res.response.statusCode != 201) {
      throw Exception(
        res.data.message ?? "Failed to create new post: ${res.response.statusCode}",
      );
    }

    return Post.fromDto(res.data.data!);
  }

  Future<List<Post>> getPostsByUserId({
    required int userId,
    required int limit,
    required int offset,
  }) async {
    final res = await _postApi.getPostsByUserId(
      userId: userId,
      limit: limit,
      offset: offset,
    );

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to get posts: ${res.response.statusCode}",
      );
    }

    return res.data.data!.map(Post.fromDto).toList();
  }
}
