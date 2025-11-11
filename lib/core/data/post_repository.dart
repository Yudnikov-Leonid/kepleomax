import 'package:kepleomax/core/models/post.dart';
import 'package:kepleomax/core/network/apis/posts/post_api.dart';
import 'package:kepleomax/core/network/apis/posts/post_dtos.dart';

class PostRepository {
  final PostApi _postApi;

  PostRepository({required PostApi postApi}) : _postApi = postApi;

  Future<Post> createNewPost({
    required String content,
    required List<String> images,
  }) async {
    final res = await _postApi.createNewPost(
      data: CreatePostRequestDto(content: content, images: images),
    );

    if (res.response.statusCode != 201) {
      throw Exception(res.data.message ?? "Failed to create new post");
    }

    return Post.fromDto(res.data.data!);
  }

  Future<List<Post>> getPostsByUserId({required int userId}) async {
    final res = await _postApi.getPostsByUserId(userId: userId);

    if (res.response.statusCode != 200) {
      throw Exception(res.data.message ?? "Failed to get posts");
    }

    return res.data.data!.map(Post.fromDto).toList();
  }
}
