import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocConsumer, BlocProvider, ReadContext;
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/models/post.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/core/presentation/user_image.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';
import 'package:kepleomax/features/editProfile/edit_profile_bottom_sheet.dart';
import 'package:kepleomax/features/user/bloc/user_bloc.dart';
import 'package:kepleomax/features/user/bloc/user_states.dart';
import 'package:kepleomax/features/user/post_widget.dart';
import 'package:num_remap/num_remap.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/presentation/colors.dart';

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

  void _onScrolled() {
    //print(_scrollController.offset);
    setState(() {});
  }

  @override
  void initState() {
    _scrollController.addListener(_onScrolled);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrolled);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UserBloc(userRepository: Dependencies.of(context).userRepository)
            ..add(UserEventLoad(userId: widget.userId)),
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
          }
        },
        builder: (context, state) {
          if (state is! UserStateBase) {
            return Scaffold(appBar: AppBar(leading: BackButton()));
          }

          final data = state.userData;
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.white.withAlpha(
                !_scrollController.hasClients
                    ? 0
                    : _scrollController.offset
                          .remap(0, 90, 0, 255)
                          .clamp(0, 255)
                          .toInt(),
              ),
              surfaceTintColor: Colors.white,
              leading: KlmBackButton(),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      if (state.userData.profile == null || state.userData.isLoading)
                        return;
                      await _editProfile(state.userData.profile!, (newProfile) {
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
                opacity: !_scrollController.hasClients
                    ? 0
                    : _scrollController.offset.remap(110, 130, 0, 1).clamp(0, 1),
                child: Text(
                  data.isLoading
                      ? '--------------'
                      : data.profile?.user.username ?? 'Failed to load username',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
              ),
            ),
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollStartNotification) {
                  // print('scroll start');
                } else if (notification is ScrollEndNotification) {
                  //print('scroll end, offset: ${_scrollController.offset}');
                  final offset = _scrollController.offset;
                  if (offset > 0 && offset <= 75) {
                    //print('scroll to index 0');
                    _scrollController.scrollToIndex(
                      0,
                      preferPosition: AutoScrollPosition.end,
                    );
                  } else if (offset > 75 && offset < 125) {
                    //print('scroll to index 1');
                    _scrollController.scrollToIndex(
                      1,
                      preferPosition: AutoScrollPosition.begin,
                    );
                  }
                }
                return false;
              },
              child: SingleChildScrollView(
                key: Key('scroll_profile'),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).viewPadding.top,
                ),
                controller: _scrollController,
                child: Skeletonizer(
                  enabled: state.userData.isLoading,
                  child: Column(
                    children: [
                      AutoScrollTag(
                        key: Key('top_scroll_tag'),
                        controller: _scrollController,
                        index: 0,
                        highlightColor: Colors.red,
                        child: Center(
                          child: UserImage(
                            url: data.profile?.user.profileImage,
                            size: 130,
                            isLoading: data.isLoading,
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
                      Text(
                        data.isLoading
                            ? '--------------'
                            : data.profile?.user.username ??
                                  'Failed to load username',
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                      if (state.userData.isLoading ||
                          (state.userData.profile?.description.isNotEmpty ??
                              false)) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            state.userData.isLoading
                                ? '-------------'
                                : state.userData.profile?.description ??
                                      'Failed to load description',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyLarge?.copyWith(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KlmColors.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () {},
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  weight: 4,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Post',
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
                      ),
                      const SizedBox(height: 10),
                      Divider(thickness: 5, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      PostWidget(
                        post: Post(
                          user: User(
                            id: 0,
                            email: '',
                            username: '---------',
                            profileImage: '',
                          ),
                          content:
                              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                          likesCount: 22,
                          createdAt: 1762682274000,
                          updatedAt: 1762682474000,
                        ),
                      ),
                      const SizedBox(height: 1000),
                      const Text('END'),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _editProfile(
    UserProfile profile,
    ValueChanged<UserProfile> onSave,
  ) async {
    AppNavigator.canPop = false;
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditProfileBottomSheet(profile: profile, onSave: onSave),
      isDismissible: false,
      //enableDrag: false,
    );
    AppNavigator.canPop = true;
  }
}
