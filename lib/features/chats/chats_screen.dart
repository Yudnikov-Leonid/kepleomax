import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/core/presentation/klm_button.dart';
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
    return Scaffold(
      appBar: KlmAppBar(context, 'Chats', key: const Key('chats_app_bar')),
      body: const _Body(key: Key('chats_body')),
    );
  }
}

/// body
class _Body extends StatelessWidget {
  const _Body({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsBloc, ChatsState>(
      builder: (context, state) {
        if (state is ChatsStateError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                KlmButton(
                  onPressed: () {
                    context.read<ChatsBloc>().add(const ChatsEventLoad());
                  },
                  width: 100,
                  text: 'Retry',
                ),
              ],
            ),
          );
        }

        if (state is! ChatsStateBase) return const SizedBox();

        final data = state.data;

        if (data.isLoading) {
          return Skeletonizer(
            child: Column(
              children: [
                _ChatWidget(chat: Chat.loading(), isLoading: true),
                _ChatWidget(chat: Chat.loading(), isLoading: true),
                _ChatWidget(chat: Chat.loading(), isLoading: true),
              ],
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
            context.read<ChatsBloc>().add(const ChatsEventLoad());
          },
          child: SizedBox(
            height: context.screenSize.height,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: data.chats
                    .map(
                      (chat) => chat.otherUser == null
                          ? const SizedBox()
                          : _ChatWidget(key: Key('chat-${chat.id}'), chat: chat),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
