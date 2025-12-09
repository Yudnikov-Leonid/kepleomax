import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/core/presentation/klm_button.dart';
import 'package:kepleomax/core/presentation/klm_error_widget.dart';
import 'package:kepleomax/core/presentation/parse_time.dart';
import 'package:kepleomax/core/presentation/user_image.dart';
import 'package:kepleomax/features/chats/bloc/chats_bloc.dart';
import 'package:kepleomax/features/chats/bloc/chats_state.dart';
import 'package:kepleomax/features/chats/chats_screen_navigator.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'widgets/chat_widget.dart';

/// screen
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _AppBar(key: Key('chats_app_bar')),
      body: _Body(key: Key('chats_body')),
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
  /// callbacks
  @override
  void initState() {
    context.read<ChatsBloc>().add(const ChatsEventLoadCache());
    super.initState();
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsBloc, ChatsState>(
      buildWhen: (oldState, newState) {
        if (newState is ChatsStateMessage) return false;
        if (oldState is ChatsStateBase && newState is ChatsStateBase) {
          return oldState.data != newState.data;
        }
        return true;
      },
      listener: (context, state) {
        if (state is ChatsStateMessage) {
          context.showSnackBar(
            text: state.message,
            color: state.isError ? KlmColors.errorRed : null,
          );
        }
      },
      builder: (context, state) {
        if (state is ChatsStateError) {
          return KlmErrorWidget(
            errorMessage: state.message,
            onRetry: () {
              context.read<ChatsBloc>().add(const ChatsEventLoad());
            },
          );
        }

        if (state is! ChatsStateBase) return const SizedBox();

        final data = state.data;

        if (data.isLoading && data.chats.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ChatsBloc>().add(const ChatsEventReconnect());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Skeletonizer(
                key: const Key('chats_loading'),
                child: Column(
                  children: [
                    _ChatWidget(chat: Chat.loading(), isLoading: true),
                    _ChatWidget(chat: Chat.loading(), isLoading: true),
                    _ChatWidget(chat: Chat.loading(), isLoading: true),
                    _ChatWidget(chat: Chat.loading(), isLoading: true),
                    _ChatWidget(chat: Chat.loading(), isLoading: true),
                  ],
                ),
              ),
            ),
          );
        }

        if (data.chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "You have no chats now",
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                KlmButton(
                  onPressed: () {
                    AppNavigator.of(context)!.push(const PeoplePage());
                  },
                  width: 200,
                  text: 'Find people',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (!data.isConnected) {
              context.read<ChatsBloc>().add(const ChatsEventReconnect());
            } else {
              context.read<ChatsBloc>().add(const ChatsEventLoad());
            }
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: data.chats.length,
            itemBuilder: (context, i) => _ChatWidget(
              key: Key('chat-${data.chats[i].id}'),
              chat: data.chats[i],
            ),
          ),
        );
      },
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsBloc, ChatsState>(
      buildWhen: (oldState, newState) {
        if (newState is! ChatsStateBase) return false;

        if (oldState is! ChatsStateBase) return true;

        return oldState.data.isLoading != newState.data.isLoading ||
            oldState.data.isConnected != newState.data.isConnected;
      },
      builder: (context, state) {
        if (state is! ChatsStateBase) return const SizedBox();

        final data = state.data;
        return KlmAppBar(
          context,
          !data.isConnected
              ? 'Connecting..'
              : data.isLoading
              ? 'Updating..'
              : 'Chats',
          key: const Key('chats_app_bar'),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
