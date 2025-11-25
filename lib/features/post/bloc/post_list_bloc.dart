import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/core/models/post.dart';
import 'package:kepleomax/features/post/bloc/post_list_state.dart';
import 'package:kepleomax/main.dart';
import 'package:ntp/ntp.dart';

const int _pagingLimit = 5;

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  final PostRepository _postRepository;

  late PostListData _data = PostListData.initial();
  final int? _userId;
  int _loadTime = 0;

  PostListBloc({required PostRepository postRepository, required int? userId})
    : _postRepository = postRepository,
      _userId = userId,
      super(PostListStateBase.initial()) {
    on<PostListEventLoad>(_onLoad);
    on<PostListEventLoadMore>(_onLoadMorePosts);
    on<PostListEventDeletePost>(_onDeletePost);
  }

  void _onLoad(PostListEventLoad event, Emitter<PostListState> emit) async {
    /// to prevent paging
    _data = _data.copyWith(isNewPostsLoading: true);
    emit(const PostListStateLoading());

    try {
      _loadTime = (await NTP.now()).millisecondsSinceEpoch;
      final posts = await _getPosts(offset: 0, beforeTime: _loadTime);

      _data = _data.copyWith(
        posts: posts,
        isAllPostsLoaded: posts.length < _pagingLimit,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PostListStateError(message: e.toString()));
    } finally {
      _data = _data.copyWith(isNewPostsLoading: false);
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
      final newPosts = await _getPosts(offset: oldPosts.length, beforeTime: _loadTime);

      _data = _data.copyWith(
        isAllPostsLoaded: newPosts.length < _pagingLimit,
        posts: <Post>{...oldPosts, ...newPosts}.toList(),

        /// TODO
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
      await _postRepository.deletePost(postId: event.postId);
      _data = _data = _data.copyWith(posts: newPosts..removeAt(event.index));
      emit(const PostListStateMessage(message: 'Post deleted'));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      _data = _data.copyWith(posts: oldPosts);
      emit(PostListStateMessage(message: e.toString(), isError: true));
    } finally {
      emit(PostListStateBase(data: _data));
    }
  }

  Future<List<Post>> _getPosts({
    required int offset,
    required int beforeTime,
  }) async {
    if (_userId == null) {
      return await _postRepository.getPosts(
        limit: _pagingLimit,
        offset: offset,
        beforeTime: beforeTime,
      );
    } else {
      return await _postRepository.getPostsByUserId(
        userId: _userId,
        limit: _pagingLimit,
        offset: offset,
        beforeTime: beforeTime
      );
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
