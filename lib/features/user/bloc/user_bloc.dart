import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/post_repository.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/models/post.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/features/user/bloc/user_states.dart';
import 'package:kepleomax/main.dart';

const int _pagingLimit = 3;

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  final PostRepository _postRepository;

  UserBloc({
    required UserRepository userRepository,
    required PostRepository postRepository,
  }) : _userRepository = userRepository,
       _postRepository = postRepository,
       super(UserStateBase.initial()) {
    on<UserEventLoad>(_onLoad);
    on<UserEventUpdateProfile>(_onUpdateProfile);
    on<UserEventLoadMorePosts>(_onLoadMorePosts);
  }

  late UserData _userData = UserData.initial();

  void _onLoadMorePosts(
    UserEventLoadMorePosts event,
    Emitter<UserState> emit,
  ) async {
    if (_userData.isNewPostsLoading) return;

    final oldPosts = _userData.posts;
    _userData = _userData.copyWith(
      isNewPostsLoading: true,
      posts: [...oldPosts, Post.loading()],
    );

    try {
      final newPosts = await _postRepository.getPostsByUserId(
        userId: _userData.profile!.user.id,
        limit: _pagingLimit,
        offset: oldPosts.length,
      );

      _userData = _userData.copyWith(
        isAllPostsLoaded: newPosts.length < _pagingLimit,
        posts: [...oldPosts, ...newPosts],
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(UserStateError(message: e.toString()));
    } finally {
      _userData = _userData.copyWith(isNewPostsLoading: false);
      emit(UserStateBase(userData: _userData));
    }
  }

  void _onLoad(UserEventLoad event, Emitter<UserState> emit) async {
    _userData = _userData.copyWith(
      isLoading: true,
      isNewPostsLoading: true,
      isAllPostsLoaded: false,
    );
    emit(UserStateBase(userData: _userData));

    final userId = event.userId;

    UserProfile? profile;
    List<Post> posts = [];

    try {
      await Future.wait([
        Future(() async {
          profile = await _userRepository.getUserProfile(userId);
        }),
        Future(() async {
          posts = await _postRepository.getPostsByUserId(
            userId: userId,
            limit: _pagingLimit,
            offset: 0,
          );
        }),
      ]);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(UserStateError(message: e.toString()));
    } finally {
      _userData = _userData.copyWith(
        profile: profile,
        posts: [..._userData.posts, ...posts],
        isLoading: false,
        isNewPostsLoading: false,
        isAllPostsLoaded: posts.length < _pagingLimit,
      );
      emit(UserStateBase(userData: _userData));
    }
  }

  void _onUpdateProfile(
    UserEventUpdateProfile event,
    Emitter<UserState> emit,
  ) async {
    if (event.newProfile == _userData.profile) {
      return;
    }

    _userData = _userData.copyWith(isLoading: true);
    emit(UserStateBase(userData: _userData));

    try {
      final newProfile = await _userRepository.updateProfile(
        event.newProfile,
        updateImage:
            _userData.profile!.user.profileImage !=
            event.newProfile.user.profileImage,
      );

      _userData = _userData.copyWith(profile: newProfile);
      emit(UserStateUpdateUser(user: newProfile.user));
      emit(UserStateMessage(message: 'Changes saved'));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(UserStateError(message: e.toString()));
    } finally {
      _userData = _userData.copyWith(isLoading: false);
      emit(UserStateBase(userData: _userData));
    }
  }
}

/// Events
abstract class UserEvent {}

class UserEventLoad implements UserEvent {
  final int userId;

  const UserEventLoad({required this.userId});
}

class UserEventUpdateProfile implements UserEvent {
  final UserProfile newProfile;

  const UserEventUpdateProfile({required this.newProfile});
}

class UserEventLoadMorePosts implements UserEvent {
  const UserEventLoadMorePosts();
}
