import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/models/chat.dart';
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

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late final PeopleBloc _bloc;

  @override
  void initState() {
    _bloc = PeopleBloc(userRepository: Dependencies.of(context).userRepository)
      ..add(const PeopleEventLoad());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PeopleBloc>(
      create: (context) => _bloc,
      child: BlocListener<PeopleBloc, PeopleState>(
        listener: (context, state) {
          if (state is PeopleStateError) {
            context.showSnackBar(text: state.message, color: KlmColors.errorRed);
          }
        },
        child: Scaffold(
          appBar: _AppBar(),
          body: _Body(bloc: _bloc),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.bloc});

  final PeopleBloc bloc;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _onScrollListener() {
    if (_scrollController.offset > _scrollController.position.maxScrollExtent - 30) {
      widget.bloc.add(const PeopleEventLoadMore());
    }
  }

  @override
  void initState() {
    _scrollController.addListener(_onScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollListener);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PeopleBloc, PeopleState>(
      builder: (context, state) {
        if (state is! PeopleStateBase) return SizedBox();

        final data = state.data;
        return SingleChildScrollView(
          key: Key('users_scroll_view'),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            key: Key('users_column'),
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
                SizedBox(height: 40, width: 40, child: CircularProgressIndicator()),
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
    );
  }
}

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
                    Text(
                      user.username,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(onPressed: () {
              AppNavigator.withKeyOf(
                context,
                mainNavigatorKey,
              )!.push(ChatPage(chat: Chat.newWithUser(user)));
            }, icon: Icon(Icons.chat_outlined)),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

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
      leading: KlmBackButton(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
