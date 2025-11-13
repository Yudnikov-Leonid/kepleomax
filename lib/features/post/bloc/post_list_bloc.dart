import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/features/post/bloc/post_list_state.dart';
import 'package:kepleomax/main.dart';

const int _pagingLimit = 4;

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
    on<PostListEventDeletePost>(_onDeletePost);
  }

  void _onDeletePost(
    PostListEventDeletePost event,
    Emitter<PostListState> emit,
  ) async {
    final oldPosts = [..._data.posts];
    final newPosts = _data.posts.toList();
    _data = _data.copyWith(
      posts: newPosts
        ..[event.index] = newPosts[event.index].copyWith(isMockLoadingPost: true),
    );
    emit(PostListStateBase(data: _data));

    try {
      await Future.delayed(const Duration(seconds: 2));
      await _postRepository.deletePost(postId: event.postId);
      _data = _data = _data.copyWith(posts: newPosts..removeAt(event.index));
      emit(PostListStateMessage(message: 'Post deleted'));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      _data = _data.copyWith(posts: oldPosts);
      emit(PostListStateMessage(message: e.toString(), isError: true));
    } finally {
      emit(PostListStateBase(data: _data));
    }
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
      emit(PostListStateMessage(message: e.toString(), isError: true));
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

class PostListEventDeletePost implements PostListEvent {
  final int index;
  final int postId;

  PostListEventDeletePost({required this.index, required this.postId});
}
