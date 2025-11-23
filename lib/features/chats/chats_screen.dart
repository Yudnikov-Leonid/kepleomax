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

/// widgets
class _ChatWidget extends StatelessWidget {
  const _ChatWidget({required this.chat, this.isLoading = false, super.key});

  final Chat chat;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 70,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                AppNavigator.withKeyOf(
                  context,
                  mainNavigatorKey,
                )!.push(ChatPage(chatId: chat.id, otherUser: chat.otherUser));
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: UserImage(url: chat.otherUser!.profileImage),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.otherUser!.username,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (chat.lastMessage != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (chat.lastMessage!.user.isCurrent)
                            Text(
                              'You: ',
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: context.screenSize.width * 0.3,
                            ),
                            child: Text(
                              chat.lastMessage!.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ' • ${ParseTime.unixTimeToPassTimeSlim(chat.lastMessage!.createdAt)}',
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (chat.lastMessage?.user.isCurrent ?? false)
                Icon(chat.lastMessage!.isRead ? Icons.check_box : Icons.check)
              else if (chat.lastMessage != null && chat.unreadCount > 0)
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: KlmColors.primaryColor,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    chat.unreadCount.toString(),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
