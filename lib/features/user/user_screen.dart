import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/core/presentation/klm_button.dart';
import 'package:kepleomax/core/presentation/user_image.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';
import 'package:kepleomax/features/chats/chats_screen_navigator.dart';
import 'package:kepleomax/features/edit_profile/edit_profile_bottom_sheet.dart';
import 'package:kepleomax/features/post/bloc/post_list_bloc.dart';
import 'package:kepleomax/features/post/post_list_widget.dart';
import 'package:kepleomax/features/user/bloc/user_bloc.dart';
import 'package:kepleomax/features/user/bloc/user_states.dart';
import 'package:num_remap/num_remap.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/presentation/colors.dart';
import '../../core/presentation/photos_preview/photos_preview_screen.dart';

const int _appBarUsernameFullShownOffset = 130;

class UserScreen extends StatefulWidget {
  const UserScreen({required this.userId, super.key});

  final int userId;

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late final _scrollController = AutoScrollController(
    viewportBoundaryGetter: () =>
        Rect.fromLTRB(0, MediaQuery.of(context).viewPadding.top, 0, 0),
  );
  late PostListBloc _postBloc;

  void _onScrollListener() {
    if (_scrollController.offset >
        _scrollController.position.maxScrollExtent - 180) {
      _postBloc.add(const PostListEventLoadMore());
    }
  }

  @override
  void initState() {
    _postBloc = PostListBloc(
      postRepository: Dependencies.of(context).postRepository,
      userId: widget.userId,
    )..add(const PostListEventLoad());
    _scrollController.addListener(_onScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserBloc(
            userRepository: Dependencies.of(context).userRepository,
            userId: widget.userId,
          )..add(const UserEventLoad()),
        ),
        BlocProvider(create: (context) => _postBloc),
      ],
      child: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserStateError) {
            context.showSnackBar(text: state.message, color: KlmColors.errorRed);
          }

          if (state is UserStateMessage) {
            context.showSnackBar(
              text: state.message,
              color: Colors.green,
              duration: const Duration(seconds: 2),
            );
          }

          if (state is UserStateUpdateUser) {
            AuthScope.updateUser(context, state.user);
            context.read<PostListBloc>().add(const PostListEventLoad());
          }
        },
        builder: (context, state) {
          if (state is! UserStateBase) {
            return Scaffold(appBar: AppBar(leading: BackButton()));
          }

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _AppBar(scrollController: _scrollController),
            body: _Body(
              scrollController: _scrollController,
              scrollPadding: MediaQuery.of(context).viewPadding.top,
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required AutoScrollController scrollController,
    required double scrollPadding,
  }) : _scrollController = scrollController,
       _scrollPadding = scrollPadding;

  final AutoScrollController _scrollController;

  /// inside this widget MediaQuery.of(context).viewPadding.top will be 0
  final double _scrollPadding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      buildWhen: (oldState, newState) {
        if (newState is! UserStateBase) return false;

        if (oldState is! UserStateBase) return true;

        return oldState.userData != newState.userData;
      },
      builder: (context, state) {
        if (state is! UserStateBase) return SizedBox();

        final data = state.userData;
        return NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<UserBloc>().add(const UserEventLoad());
              context.read<PostListBloc>().add(const PostListEventLoad());
            },
            child: SingleChildScrollView(
              key: Key('scroll_profile'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: _scrollPadding),
              controller: _scrollController,
              child: Column(
                children: [
                  Skeletonizer(
                    key: Key('screen_top_skeletonizer'),
                    enabled: data.isLoading,
                    child: Column(
                      children: [
                        AutoScrollTag(
                          key: Key('top_scroll_tag'),
                          controller: _scrollController,
                          index: 0,
                          highlightColor: Colors.red,
                          child: Center(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap:
                                  data.profile == null ||
                                      (data.profile?.user.profileImage.isEmpty ??
                                          true)
                                  ? null
                                  : () {
                                      AppNavigator.showGeneralDialog(
                                        context,
                                        PhotosPreviewScreen(
                                          urls: [data.profile!.user.profileImage],
                                          initialIndex: 0,
                                          isOnePictureMode: true,
                                        ),
                                      );
                                    },
                              child: UserImage(
                                url: data.profile?.user.profileImage,
                                size: 130,
                                isLoading: data.isLoading,
                              ),
                            ),
                          ),
                        ),
                        AutoScrollTag(
                          key: Key('bottom_of_username_scroll_tag'),
                          controller: _scrollController,
                          index: 1,
                          highlightColor: Colors.red,
                          child: const SizedBox(height: 16),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            data.isLoading
                                ? '--------------'
                                : data.profile?.user.username ??
                                      'Failed to load username',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                          ),
                        ),
                        if (data.isLoading ||
                            (data.profile?.description.isNotEmpty ?? false)) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              data.isLoading
                                  ? '-------------'
                                  : data.profile?.description ??
                                        'Failed to load description',
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyLarge?.copyWith(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (!data.isLoading && data.profile == null) ...[
                          KlmButton(
                            onPressed: () {
                              context.read<UserBloc>().add(UserEventLoad());
                            },
                            text: 'Retry',
                            width: 120,
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (!data.isLoading && data.profile != null) ...[
                          if (data.profile?.user.isCurrent ?? false)
                            _actionButton(
                              context,
                              text: 'Post',
                              icon: Icons.add,
                              action: () {
                                AppNavigator.withKeyOf(
                                  context,
                                  mainNavigatorKey,
                                )!.push(
                                  PostEditorPage(
                                    post: null,
                                    onPostSaved: () {
                                      context.read<PostListBloc>().add(
                                        const PostListEventLoad(),
                                      );
                                    },
                                  ),
                                );
                              },
                            )
                          else
                            _actionButton(
                              context,
                              text: 'Message',
                              icon: Icons.message_sharp,
                              action: () {
                                AppNavigator.withKeyOf(
                                  context,
                                  mainNavigatorKey,
                                )!.push(
                                  ChatPage(
                                    chat: Chat.newWithUser(data.profile!.user),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 10),
                        ],
                        Divider(thickness: 5, color: Colors.grey.shade300),
                        const SizedBox(height: 10),

                        //PostListWidget(key: Key('post_of_user_$_userId'), userId: _userId),
                      ],
                    ),
                  ),
                  PostListWidget(key: Key('users_posts'), isUserPage: true),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final offset = _scrollController.offset;
      if (offset > 0 && offset <= 75) {
        _scrollController.scrollToIndex(0, preferPosition: AutoScrollPosition.end);
      } else if (offset > 75 && offset < 125) {
        _scrollController.scrollToIndex(1, preferPosition: AutoScrollPosition.begin);
      }
    }
    return false;
  }

  Widget _actionButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required VoidCallback action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: KlmColors.primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextButton(
          onPressed: action,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, weight: 4, color: Colors.white, size: 24),
              const SizedBox(width: 4),
              Text(
                text,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatefulWidget implements PreferredSizeWidget {
  const _AppBar({required AutoScrollController scrollController})
    : _scrollController = scrollController;

  final AutoScrollController _scrollController;

  @override
  State<_AppBar> createState() => _AppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _AppBarState extends State<_AppBar> {
  @override
  void initState() {
    widget._scrollController.addListener(_onScrolledListener);
    super.initState();
  }

  @override
  void dispose() {
    widget._scrollController.removeListener(_onScrolledListener);
    super.dispose();
  }

  double _lastScrollPosition = 0;

  void _onScrolledListener() {
    final currentOffset = widget._scrollController.offset;

    /// cause you can scroll really fast and skip _appBarUsernameFullShownOffset offset
    if (currentOffset > _appBarUsernameFullShownOffset &&
        _lastScrollPosition > _appBarUsernameFullShownOffset) {
      return;
    }
    _lastScrollPosition = currentOffset;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      buildWhen: (oldState, newState) {
        if (newState is! UserStateBase) return false;

        if (oldState is! UserStateBase) return true;

        final oldData = oldState.userData;
        final newData = newState.userData;

        return oldData.isLoading != newData.isLoading ||
            oldData.profile?.user.isCurrent != newData.profile?.user.isCurrent ||
            oldData.profile?.user.username != newData.profile?.user.username;
      },
      builder: (context, state) {
        if (state is! UserStateBase) return SizedBox();

        final data = state.userData;
        return AppBar(
          backgroundColor: Colors.white.withAlpha(
            !widget._scrollController.hasClients
                ? 0
                : widget._scrollController.offset
                      .remap(0, 90, 0, 255)
                      .clamp(0, 255)
                      .toInt(),
          ),
          surfaceTintColor: Colors.white,
          leading: KlmBackButton(),
          actions: [
            if (!data.isLoading && (data.profile?.user.isCurrent ?? false))
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    if (data.profile == null || data.isLoading) return;
                    await _editProfile(context, data.profile!, (newProfile) {
                      context.read<UserBloc>().add(
                        UserEventUpdateProfile(newProfile: newProfile),
                      );
                    });
                  } else if (value == 'logout') {
                    AuthScope.logout(context);
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text(
                      'Edit profile',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Text(
                      'Logout',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
          ],
          centerTitle: true,
          title: Opacity(
            opacity: !widget._scrollController.hasClients
                ? 0
                : widget._scrollController.offset
                      .remap(110, _appBarUsernameFullShownOffset, 0, 1)
                      .clamp(0, 1),
            child: Text(
              data.isLoading
                  ? ''
                  : data.profile?.user.username ?? 'Failed to load username',
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editProfile(
    BuildContext context,
    UserProfile profile,
    ValueChanged<UserProfile> onSave,
  ) async {
    AppNavigator.of(context)!.showModalBottomSheet(
      context,
      EditProfileBottomSheet(profile: profile, onSave: onSave),
    );
  }
}
