import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/features/post/bloc/post_list_state.dart';
import 'package:kepleomax/main.dart';

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  final PostRepository _postRepository;

  PostListBloc({required PostRepository postRepository})
    : _postRepository = postRepository,
      super(PostListStateBase(posts: [])) {
    on<PostListEventLoad>(_onLoad);
  }

  void _onLoad(PostListEventLoad event, Emitter<PostListState> emit) async {
    emit(const PostListStateLoading());

    try {
      final posts = await _postRepository.getPostsByUserId(userId: event.userId);

      emit(PostListStateBase(posts: posts));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PostListStateError(message: e.toString()));
    }
  }
}

/// events
abstract class PostListEvent {}

class PostListEventLoad implements PostListEvent {
  final int userId;

  const PostListEventLoad({required this.userId});
}
