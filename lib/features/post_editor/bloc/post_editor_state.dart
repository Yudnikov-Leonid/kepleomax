import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/post.dart';
import 'package:kepleomax/core/presentation/image_url_or_file.dart';

part 'post_editor_state.freezed.dart';

abstract class PostEditorState {}

@freezed
abstract class PostEditorStateBase
    with _$PostEditorStateBase
    implements PostEditorState {
  const factory PostEditorStateBase({
    required PostEditorData data,
    @Default(false) bool updateControllers,
  }) = _PostEditorStateBase;

  factory PostEditorStateBase.initial() =>
      PostEditorStateBase(data: PostEditorData.initial());
}

@freezed
abstract class PostEditorStateError
    with _$PostEditorStateError
    implements PostEditorState {
  const factory PostEditorStateError({required String message}) =
      _PostEditorStateError;
}

@freezed
abstract class PostEditorStateExit
    with _$PostEditorStateExit
    implements PostEditorState {
  const factory PostEditorStateExit({required bool refreshPostsList}) =
      _PostEditorStateExit;
}

@freezed
abstract class PostEditorData with _$PostEditorData {

  const factory PostEditorData({
    Post? originalPost,
    required String text,
    required List<ImageUrlOrFile> images,
    @Default(false) bool isLoading,
  }) = _PostEditorData;

  factory PostEditorData.initial() => const PostEditorData(text: '', images: []);

  factory PostEditorData.fromPost(Post post) => PostEditorData(
    originalPost: post,
    text: post.content,
    images: post.images.map((url) => ImageUrlOrFile(url: url)).toList(),
  );
  const PostEditorData._();

  bool isEmpty() => text.isEmpty && images.isEmpty;
}
