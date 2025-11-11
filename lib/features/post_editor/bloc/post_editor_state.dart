import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_editor_state.freezed.dart';

abstract class PostEditorState {}

@freezed
abstract class PostEditorStateBase
    with _$PostEditorStateBase
    implements PostEditorState {
  const factory PostEditorStateBase({required PostEditorData data}) =
      _PostEditorStateBase;

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
abstract class PostEditorStateExit with _$PostEditorStateExit implements PostEditorState {
  const factory PostEditorStateExit() = _PostEditorStateExit;
}

@freezed
abstract class PostEditorData with _$PostEditorData {
  const PostEditorData._();

  const factory PostEditorData({
    required String text,
    required List<ImageUrlOrFile> images,
    required bool isLoading,
  }) = _PostEditorData;

  bool isEmpty() => text.isEmpty && images.isEmpty;

  factory PostEditorData.initial() =>
      PostEditorData(text: '', images: [], isLoading: false);
}

@freezed
abstract class ImageUrlOrFile with _$ImageUrlOrFile {
  const factory ImageUrlOrFile({String? url, File? file}) = _ImageUrlOrFile;
}
