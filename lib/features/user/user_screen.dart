import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/di/dependencies.dart';
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

/// screen
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

  /// callbacks
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserBloc>(
      create: (context) => UserBloc(
        userRepository: Dependencies.of(context).userRepository,
        userId: widget.userId,
      )..add(const UserEventLoad()),
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
            return Scaffold(appBar: AppBar(leading: const BackButton()));
          }

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _AppBar(
              scrollController: _scrollController,
              userId: widget.userId,
              key: const Key('user_app_bar'),
            ),
            body: _ScrollControllerListeners(
              controller: _scrollController,
              userId: widget.userId,
              child: _Body(
                scrollController: _scrollController,
                scrollPadding: MediaQuery.of(context).viewPadding.top,
                key: const Key('user_screen_body'),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// body
class _Body extends StatelessWidget {
  const _Body({
    required AutoScrollController scrollController,
    required double scrollPadding,
    super.key,
  }) : _scrollController = scrollController,
       _scrollPadding = scrollPadding;

  /// inside this widget MediaQuery.of(context).viewPadding.top will be 0
  final double _scrollPadding;
  final AutoScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      buildWhen: (oldState, newState) {
        if (newState is! UserStateBase) return false;

        if (oldState is! UserStateBase) return true;

        return oldState.userData != newState.userData;
      },
      builder: (context, state) {
        if (state is! UserStateBase) return const SizedBox();

        final data = state.userData;
        return RefreshIndicator(
          onRefresh: () async {
            context.read<UserBloc>().add(const UserEventLoad());
            context.read<PostListBloc>().add(const PostListEventLoad());
          },
          child: SingleChildScrollView(
            key: const Key('scroll_profile'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: _scrollPadding),
            controller: _scrollController,
            child: Skeletonizer(
              key: const Key('screen_top_skeletonizer'),
              enabled: data.isLoading,
              child: Column(
                children: [
                  /// user image
                  AutoScrollTag(
                    key: const Key('top_scroll_tag'),
                    controller: _scrollController,
                    index: 0,
                    highlightColor: Colors.red,
                    child: Center(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap:
                            data.profile == null ||
                                (data.profile?.user.profileImage.isEmpty ?? true)
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
                    key: const Key('bottom_of_username_scroll_tag'),
                    controller: _scrollController,
                    index: 1,
                    highlightColor: Colors.red,
                    child: const SizedBox(height: 16),
                  ),

                  /// username
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      data.isLoading
                          ? '--------------'
                          : data.profile?.user.username ?? 'Failed to load username',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  ),

                  /// description
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
                        context.read<UserBloc>().add(const UserEventLoad());
                        context.read<PostListBloc>().add(const PostListEventLoad());
                      },
                      text: 'Retry',
                      width: 120,
                    ),
                    const SizedBox(height: 10),
                  ],

                  /// action button
                  if (!data.isLoading && data.profile != null) ...[
                    _ActionButton(
                      isCurrentUser: data.profile!.user.isCurrent,
                      navigateToPage: data.profile!.user.isCurrent
                          ? PostEditorPage(
                              post: null,
                              onPostSaved: () {
                                context.read<PostListBloc>().add(
                                  const PostListEventLoad(),
                                );
                              },
                            )
                          : ChatPage(chatId: -1, otherUser: data.profile!.user),
                    ),
                    const SizedBox(height: 10),
                  ],

                  /// posts
                  Divider(thickness: 5, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  const PostListWidget(key: Key('users_posts'), isUserPage: true),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// widgets
class _ScrollControllerListeners extends StatefulWidget {
  const _ScrollControllerListeners({
    required this.controller,
    required this.userId,
    required this.child,
  });

  final AutoScrollController controller;
  final int userId;
  final Widget child;

  @override
  State<_ScrollControllerListeners> createState() =>
      _ScrollControllerListenersState();
}

class _ScrollControllerListenersState extends State<_ScrollControllerListeners> {
  late PostListBloc _postBloc;

  /// callbacks
  @override
  void initState() {
    _postBloc = PostListBloc(
      postRepository: Dependencies.of(context).postRepository,
      userId: widget.userId,
    )..add(const PostListEventLoad());
    widget.controller.addListener(_onScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScrollListener);
    super.dispose();
  }

  /// listeners
  void _onScrollListener() {
    if (widget.controller.offset >
        widget.controller.position.maxScrollExtent - 180) {
      _postBloc.add(const PostListEventLoadMore());
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final offset = widget.controller.offset;
      if (offset > 0 && offset <= 75) {
        widget.controller.scrollToIndex(0, preferPosition: AutoScrollPosition.end);
      } else if (offset > 75 && offset < 125) {
        widget.controller.scrollToIndex(1, preferPosition: AutoScrollPosition.begin);
      }
    }
    return false;
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostListBloc>(
      create: (context) => _postBloc,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: widget.child,
      ),
    );
  }
}

class _AppBar extends StatefulWidget implements PreferredSizeWidget {
  const _AppBar({required this.scrollController, required this.userId, super.key});

  final AutoScrollController scrollController;
  final int userId;

  @override
  State<_AppBar> createState() => _AppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarState extends State<_AppBar> {
  /// callbacks
  @override
  void initState() {
    widget.scrollController.addListener(_onScrolledListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScrolledListener);
    super.dispose();
  }

  /// should be here, not in _ScrollControllerListeners cause setState
  /// must rebuild only this widget, not body
  /// listeners
  double _lastScrollPosition = 0;

  void _onScrolledListener() {
    final currentOffset = widget.scrollController.offset;

    /// cause you can scroll really fast and skip _appBarUsernameFullShownOffset offset
    if (currentOffset > _appBarUsernameFullShownOffset &&
        _lastScrollPosition > _appBarUsernameFullShownOffset) {
      return;
    }
    _lastScrollPosition = currentOffset;

    setState(() {});
  }

  /// build
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
        if (state is! UserStateBase) return const SizedBox();

        /// main content
        final data = state.userData;
        return AppBar(
          backgroundColor: Colors.white.withAlpha(
            !widget.scrollController.hasClients
                ? 0
                : widget.scrollController.offset
                      .remap(0, 90, 0, 255)
                      .clamp(0, 255)
                      .toInt(),
          ),
          surfaceTintColor: Colors.white,
          leading: const KlmBackButton(),
          actions: [
            if (!data.isLoading && (data.profile?.user.isCurrent ?? false))
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    if (data.profile == null || data.isLoading) return;
                    AppNavigator.of(context)!.showModalBottomSheet(
                      context,
                      EditProfileBottomSheet(
                        profile: data.profile!,
                        onSave: (newProfile) {
                          context.read<UserBloc>().add(
                            UserEventUpdateProfile(newProfile: newProfile),
                          );
                        },
                      ),
                    );
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
              )
            else if (!data.isLoading && widget.userId == AuthScope.userOf(context).id)
              TextButton(
                onPressed: () {
                  AuthScope.logout(context);
                },
                style: TextButton.styleFrom(
                  surfaceTintColor: Colors.transparent,
                  overlayColor: KlmColors.errorRed
                ),
                child: Text(
                  'Logout',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: KlmColors.errorRed,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
          ],
          centerTitle: true,
          title: Opacity(
            opacity: !widget.scrollController.hasClients
                ? 0
                : widget.scrollController.offset
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
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.isCurrentUser, required this.navigateToPage});

  final bool isCurrentUser;
  final AppPage navigateToPage;

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {
            AppNavigator.withKeyOf(context, mainNavigatorKey)!.push(navigateToPage);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCurrentUser ? Icons.add : Icons.message_sharp,
                weight: 4,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 4),
              Text(
                isCurrentUser ? 'Post' : 'Message',
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
