import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kepleomax/core/data/files_repository.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/features/post_editor/bloc/post_editor_state.dart';
import 'package:kepleomax/main.dart';

const imagesCountLimit = 5;

class PostEditorBloc extends Bloc<PostEditorEvent, PostEditorState> {
  late PostEditorData _data = PostEditorData.initial();
  final PostRepository _repository;
  final FilesRepository _filesRepository;

  PostEditorBloc(
      {required PostRepository postRepository, required FilesRepository filesRepository})
      : _repository = postRepository,
        _filesRepository = filesRepository,
        super(PostEditorStateBase.initial()) {
    on<PostEditorEventPost>(_onPost);
    on<PostEditorEventEditText>(_onEditText);
    on<PostEditorEventAddPhotos>(_onAddPhotos);
    on<PostEditorEventRemovePhoto>(_onRemovePhoto);
    on<PostEditorEventSwapPhotos>(_onSwapPhotos);
  }

  void _onPost(PostEditorEventPost post, Emitter<PostEditorState> emit) async {
    if (_data.text.isEmpty && _data.images.isEmpty) {
      emit(PostEditorStateError(message: "Post can't be empty"));
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

      await _repository.createNewPost(content: _data.text, images: imagesList);

      emit(const PostEditorStateExit(refreshPostsList: true));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PostEditorStateError(message: e.toString()));
      _data = _data.copyWith(isLoading: false);
      emit(PostEditorStateBase(data: _data));
    }
  }

  void _onEditText(PostEditorEventEditText event, Emitter<PostEditorState> emit) {
    _data = _data.copyWith(text: event.newText);
    emit(PostEditorStateBase(data: _data));
  }

  void _onAddPhotos(PostEditorEventAddPhotos event,
      Emitter<PostEditorState> emit,) async {
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

  void _onRemovePhoto(PostEditorEventRemovePhoto event,
      Emitter<PostEditorState> emit,) {
    final index = event.index;
    final newList = <ImageUrlOrFile>[];

    for (int i = 0; i < _data.images.length; i++) {
      if (i == index) continue;
      newList.add(_data.images[i]);
    }

    _data = _data.copyWith(images: newList);
    emit(PostEditorStateBase(data: _data));
  }

  void _onSwapPhotos(PostEditorEventSwapPhotos event,
      Emitter<PostEditorState> emit,) {
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
}

/// events
abstract class PostEditorEvent {}

class PostEditorEventPost implements PostEditorEvent {
  const PostEditorEventPost();
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
