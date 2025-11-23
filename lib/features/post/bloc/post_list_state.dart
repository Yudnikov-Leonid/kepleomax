import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/post.dart';

part 'post_list_state.freezed.dart';

abstract class PostListState {}

@freezed
abstract class PostListStateBase with _$PostListStateBase implements PostListState {
  const factory PostListStateBase({required PostListData data}) = _PostListStateBase;

  factory PostListStateBase.initial() =>
      PostListStateBase(data: PostListData.initial());
}

@freezed
abstract class PostListStateError
    with _$PostListStateError
    implements PostListState {
  const factory PostListStateError({required String message}) = _PostListStateError;
}

@freezed
abstract class PostListStateMessage
    with _$PostListStateMessage
    implements PostListState {
  const factory PostListStateMessage({
    required String message,
    @Default(false) bool isError,
  }) = _PostListStateMessage;
}

@freezed
abstract class PostListStateLoading
    with _$PostListStateLoading
    implements PostListState {
  const factory PostListStateLoading() = _PostListStateLoading;
}

@freezed
abstract class PostListData with _$PostListData {
  const factory PostListData({
    required List<Post> posts,
    @Default(false) bool isNewPostsLoading,
    @Default(false) bool isAllPostsLoaded,
  }) = _PostListData;

  factory PostListData.initial() => const PostListData(posts: []);
}
