import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/core/presentation/klm_textfield.dart';
import 'package:kepleomax/core/presentation/user_image.dart';
import 'package:kepleomax/features/chats/chats_screen_navigator.dart';
import 'package:kepleomax/features/people/bloc/people_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'bloc/people_bloc.dart';

/// screen
class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PeopleBloc>(
      create: (context) =>
          PeopleBloc(userRepository: Dependencies.of(context).userRepository)
            ..add(const PeopleEventLoad()),
      child: BlocListener<PeopleBloc, PeopleState>(
        listener: (context, state) {
          if (state is PeopleStateError) {
            context.showSnackBar(text: state.message, color: KlmColors.errorRed);
          }
        },
        child: const Scaffold(
          appBar: _AppBar(key: Key('people_app_bar')),
          body: _Body(key: Key('people_body')),
        ),
      ),
    );
  }
}

/// body
class _Body extends StatefulWidget {
  const _Body({super.key});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  /// callbacks
  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return _PagingListener(
      key: const Key('people_paging_listener'),
      scrollController: _scrollController,
      child: BlocBuilder<PeopleBloc, PeopleState>(
        builder: (context, state) {
          if (state is! PeopleStateBase) return const SizedBox();

          final data = state.data;
          return SingleChildScrollView(
            key: const Key('users_scroll_view'),
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              key: const Key('users_column'),
              children: [
                KlmTextField(
                  controller: _controller,
                  onChanged: (search) {
                    context.read<PeopleBloc>().add(
                      PeopleEventEditSearch(text: search),
                    );
                  },
                  hint: 'Search',
                ),
                const SizedBox(height: 20),
                if (data.isLoading)
                  const SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(),
                  ),
                ...data.users.map(
                  (user) => _UserCard(key: Key('user_card_${user.id}'), user: user),
                ),
                if (!data.isAllUsersLoaded && !data.isLoading)
                  _UserCard(user: User.loading(), isLoading: true),
                if (!data.isLoading && data.users.isEmpty)
                  Text(
                    'No one found',
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// widgets
class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, this.isLoading = false, super.key});

  final User user;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                  AppNavigator.push(context, UserPage(userId: user.id));
                },
                child: Row(
                  children: [
                    SizedBox(
                      height: 55,
                      width: 55,
                      child: UserImage(url: user.profileImage),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        user.username,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                AppNavigator.withKeyOf(
                  context,
                  mainNavigatorKey,
                )!.push(ChatPage(chatId: -1, otherUser: user));
              },
              icon: const Icon(Icons.chat_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _PagingListener extends StatefulWidget {
  const _PagingListener({
    required this.scrollController,
    required this.child,
    super.key,
  });

  final Widget child;
  final ScrollController scrollController;

  @override
  State<_PagingListener> createState() => _PagingListenerState();
}

class _PagingListenerState extends State<_PagingListener> {
  /// callbacks
  @override
  void initState() {
    widget.scrollController.addListener(_onScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScrollListener);
    super.dispose();
  }

  /// listeners
  void _onScrollListener() {
    if (widget.scrollController.offset >
        widget.scrollController.position.maxScrollExtent - 30) {
      context.read<PeopleBloc>().add(const PeopleEventLoadMore());
    }
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        'People',
        style: context.textTheme.bodyLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
      leading: const KlmBackButton(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
