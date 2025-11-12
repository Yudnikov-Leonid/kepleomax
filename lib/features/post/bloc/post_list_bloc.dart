import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/features/post/bloc/post_list_state.dart';
import 'package:kepleomax/main.dart';

const int _pagingLimit = 3;

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  final PostRepository _postRepository;

  late PostListData _data = PostListData.initial();
  final int _userId;

  PostListBloc({required PostRepository postRepository, required int userId})
    : _postRepository = postRepository,
      _userId = userId,
      super(PostListStateBase.initial()) {
    on<PostListEventLoad>(_onLoad);
    on<PostListEventLoadMore>(_onLoadMorePosts);
  }

  void _onLoadMorePosts(
    PostListEventLoadMore event,
    Emitter<PostListState> emit,
  ) async {
    if (_data.isNewPostsLoading || _data.isAllPostsLoaded) return;

    _data = _data.copyWith(isNewPostsLoading: true);
    emit(PostListStateBase(data: _data));

    final oldPosts = _data.posts;
    try {
      final newPosts = await _postRepository.getPostsByUserId(
        userId: _userId,
        limit: _pagingLimit,
        offset: oldPosts.length,
      );

      await Future.delayed(const Duration(seconds: 1));

      _data = _data.copyWith(
        isAllPostsLoaded: newPosts.length < _pagingLimit,
        posts: [...oldPosts, ...newPosts],
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      _data = _data.copyWith(isAllPostsLoaded: true);
      emit(PostListStateError(message: e.toString()));
    } finally {
      _data = _data.copyWith(isNewPostsLoading: false);
      emit(PostListStateBase(data: _data));
    }
  }

  void _onLoad(PostListEventLoad event, Emitter<PostListState> emit) async {
    emit(const PostListStateLoading());

    try {
      final posts = await _postRepository.getPostsByUserId(
        userId: _userId,
        limit: _pagingLimit,
        offset: 0,
      );

      _data = _data.copyWith(
        posts: posts,
        isAllPostsLoaded: posts.length < _pagingLimit,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PostListStateError(message: e.toString()));
    } finally {
      emit(PostListStateBase(data: _data));
    }
  }
}

/// events
abstract class PostListEvent {}

class PostListEventLoad implements PostListEvent {
  const PostListEventLoad();
}

class PostListEventLoadMore implements PostListEvent {
  const PostListEventLoadMore();
}
