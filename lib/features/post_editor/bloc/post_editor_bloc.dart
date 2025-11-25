import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kepleomax/core/data/files_repository.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/core/models/post.dart';
import 'package:kepleomax/core/presentation/image_url_or_file.dart';
import 'package:kepleomax/features/post_editor/bloc/post_editor_state.dart';
import 'package:kepleomax/main.dart';

const imagesCountLimit = 5;

class PostEditorBloc extends Bloc<PostEditorEvent, PostEditorState> {
  late PostEditorData _data = PostEditorData.initial();
  final PostRepository _repository;
  final FilesRepository _filesRepository;

  PostEditorBloc({
    required PostRepository postRepository,
    required FilesRepository filesRepository,
  }) : _repository = postRepository,
       _filesRepository = filesRepository,
       super(PostEditorStateBase.initial()) {
    on<PostEditorEventSave>(_onSave);
    on<PostEditorEventEditText>(_onEditText);
    on<PostEditorEventAddPhotos>(_onAddPhotos);
    on<PostEditorEventRemovePhoto>(_onRemovePhoto);
    on<PostEditorEventSwapPhotos>(_onSwapPhotos);
    on<PostEditorEventLoad>(_onLoad);
  }

  void _onLoad(PostEditorEventLoad event, Emitter<PostEditorState> emit) async {
    if (event.post == null) return;

    _data = PostEditorData.fromPost(event.post!);
    emit(PostEditorStateBase(data: _data, updateControllers: true));
  }

  void _onSave(PostEditorEventSave post, Emitter<PostEditorState> emit) async {
    if (_data.text.isEmpty && _data.images.isEmpty) {
      emit(const PostEditorStateError(message: "Post can't be empty"));
    }

    _data = _data.copyWith(isLoading: true);
    emit(PostEditorStateBase(data: _data));

    try {
      final imagesList = <String>[];
      for (final image in _data.images) {
        if (image.url != null) {
          imagesList.add(image.url!);
        } else {
          final url = await _filesRepository.uploadFile(image.file!.path);
          imagesList.add(url);
        }
      }

      bool refreshPostsList = true;
      if (_data.originalPost == null) {
        await _repository.createNewPost(content: _data.text.trim(), images: imagesList);
      } else {
        final isSomethingChanged = _data.text != _data.originalPost!.content ||
            !const ListEquality().equals(_data.images, _data.originalPost!.images);
        if (isSomethingChanged) {
          await _repository.updatePost(
            postId: _data.originalPost!.id,
            content: _data.text,
            images: imagesList,
          );
        } else {
          refreshPostsList = false;
        }
      }

      emit(PostEditorStateExit(refreshPostsList: refreshPostsList));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PostEditorStateError(message: e.toString()));
      _data = _data.copyWith(isLoading: false);
      emit(PostEditorStateBase(data: _data));
    }
  }

  void _onAddPhotos(
    PostEditorEventAddPhotos event,
    Emitter<PostEditorState> emit,
  ) async {
    if (_data.images.length >= imagesCountLimit) {
      emit(const PostEditorStateError(message: 'Photo limit reached'));
      emit(PostEditorStateBase(data: _data));
      return;
    }

    try {
      final maxCount = imagesCountLimit - _data.images.length;

      List<XFile> images;
      if (maxCount == 1) {
        final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
        if (image != null) {
          images = [image];
        } else {
          images = [];
        }
      } else {
        images = await ImagePicker().pickMultiImage(
          imageQuality: 70,
          limit: maxCount,
        );
        if (images.length > maxCount) {
          // should be here cause bug with pickMultiImage()
          images = images.sublist(0, maxCount);
          emit(const PostEditorStateError(message: 'Photo limit reached'));
          emit(PostEditorStateBase(data: _data));
        }
      }

      if (images.isEmpty) return;

      _data = _data.copyWith(
        images: [
          ..._data.images,
          ...images.map((xFile) => ImageUrlOrFile(file: File(xFile.path))),
        ],
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PostEditorStateError(message: e.toString()));
    } finally {
      emit(PostEditorStateBase(data: _data));
    }
  }

  void _onRemovePhoto(
    PostEditorEventRemovePhoto event,
    Emitter<PostEditorState> emit,
  ) {
    final index = event.index;
    final newList = <ImageUrlOrFile>[];

    for (int i = 0; i < _data.images.length; i++) {
      if (i == index) continue;
      newList.add(_data.images[i]);
    }

    _data = _data.copyWith(images: newList);
    emit(PostEditorStateBase(data: _data));
  }

  void _onSwapPhotos(
    PostEditorEventSwapPhotos event,
    Emitter<PostEditorState> emit,
  ) {
    final indexOne = event.indexOne;
    final indexTwo = event.indexTwo;
    final oldList = _data.images;
    final newList = <ImageUrlOrFile>[];

    for (int i = 0; i < oldList.length; i++) {
      if (i == indexOne) {
        newList.add(oldList[indexTwo]);
      } else if (i == indexTwo) {
        newList.add(oldList[indexOne]);
      } else {
        newList.add(oldList[i]);
      }
    }

    _data = _data.copyWith(images: newList);
    emit(PostEditorStateBase(data: _data));
  }

  void _onEditText(PostEditorEventEditText event, Emitter<PostEditorState> emit) {
    _data = _data.copyWith(text: event.newText);
    emit(PostEditorStateBase(data: _data));
  }
}

/// events
abstract class PostEditorEvent {}

class PostEditorEventSave implements PostEditorEvent {
  const PostEditorEventSave();
}

class PostEditorEventEditText implements PostEditorEvent {
  final String newText;

  const PostEditorEventEditText({required this.newText});
}

class PostEditorEventAddPhotos implements PostEditorEvent {
  const PostEditorEventAddPhotos();
}

class PostEditorEventRemovePhoto implements PostEditorEvent {
  final int index;

  PostEditorEventRemovePhoto({required this.index});
}

class PostEditorEventSwapPhotos implements PostEditorEvent {
  final int indexOne;
  final int indexTwo;

  PostEditorEventSwapPhotos({required this.indexOne, required this.indexTwo});
}

class PostEditorEventLoad implements PostEditorEvent {
  final Post? post;

  PostEditorEventLoad({required this.post});
}
