import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/post.dart';

part 'post_list_state.freezed.dart';

abstract class PostListState {}

@freezed
abstract class PostListStateBase with _$PostListStateBase implements PostListState {
  const factory PostListStateBase({required List<Post> posts}) = _PostListStateBase;
}

@freezed
abstract class PostListStateError with _$PostListStateError implements PostListState {
  const factory PostListStateError({required String message}) = _PostListStateError;
}

@freezed
abstract class PostListStateLoading with _$PostListStateLoading implements PostListState {
  const factory PostListStateLoading() = _PostListStateLoading;
}

// @freezed
// abstract class PostListData with _$PostListData {
//   const factory PostListData({required List<Post> posts, required bool isLoading}) = _PostListData;
//
//   factory PostListData.initial() => PostListData(posts: [], isLoading: false);
// }