import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/notifications/notifications_service.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/core/presentation/klm_error_widget.dart';
import 'package:kepleomax/core/presentation/klm_textfield.dart';
import 'package:kepleomax/core/presentation/parse_time.dart';
import 'package:kepleomax/core/presentation/user_image.dart';
import 'package:kepleomax/features/chat/bloc/chat_bloc.dart';
import 'package:kepleomax/features/chat/bloc/chat_state.dart';
import 'package:kepleomax/features/chats/bloc/chats_bloc.dart';
import 'package:kepleomax/features/chats/bloc/chats_state.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

part 'widgets/chat_bottom.dart';

part 'widgets/message_widget.dart';

part 'widgets/read_button.dart';

part 'widgets/tech_message.dart';

/// screen
class ChatScreen extends StatefulWidget {
  const ChatScreen({required this.chatId, required this.otherUser, super.key});

  final int chatId;
  final User? otherUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  late ChatBloc _chatBloc;

  /// callbacks
  @override
  void initState() {
    final dp = Dependencies.of(context);
    _chatBloc = ChatBloc(
      chatsRepository: dp.chatsRepository,
      messagesRepository: dp.messagesRepository,
      connectionRepository: dp.connectionRepository,
      chatId: widget.chatId,
    )..add(ChatEventInit(chatId: widget.chatId, otherUser: widget.otherUser));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _chatBloc,
      child: Builder(
        builder: (context) {
          /// ping to call init
          context.read<ChatBloc>();

          return Scaffold(
            resizeToAvoidBottomInset: true,
            floatingActionButton: _ReadButton(
              scrollController: _scrollController,
              chatId: widget.chatId,
              key: const Key('chat_read_button'),
            ),
            appBar: const _AppBar(key: Key('chat_appbar')),
            body: _Body(
              scrollController: _scrollController,
              onRetry: () {
                _chatBloc.add(
                  ChatEventLoad(
                    chatId: widget.chatId,
                    otherUser: widget.otherUser,
                    withCache: false,
                  ),
                );
              },
              key: const Key('chat_body'),
            ),
          );
        },
      ),
    );
  }
}

/// body
class _Body extends StatefulWidget {
  const _Body({required this.scrollController, required this.onRetry, super.key});

  final ScrollController scrollController;
  final VoidCallback onRetry;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool _isScreenActive = false;
  late final ChatBloc _chatBloc;

  /// callbacks
  @override
  void initState() {
    _chatBloc = context.read<ChatBloc>();
    widget.scrollController.addListener(_onScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScrollListener);
    super.dispose();
  }

  void _onResume(int chatId) {
    _isScreenActive = true;
    NotificationService.instance.blockNotificationsFromChat(chatId);
    _onScrollListener();
  }

  void _onPause() {
    _isScreenActive = false;
    NotificationService.instance.enableAllNotifications();
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      buildWhen: (oldState, newState) {
        if (newState is ChatStateMessage || oldState is ChatStateMessage)
          return false;

        if (oldState is ChatStateBase && newState is ChatStateBase) {
          final oldData = oldState.data;
          final newData = newState.data;
          return oldData.isLoading != newData.isLoading ||
              !listEquals(oldData.messages, newData.messages) ||
              oldData.isAllMessagesLoaded != newData.isAllMessagesLoaded;
        }

        return true;
      },
      listener: (context, state) {
        if (state is ChatStateMessage) {
          context.showSnackBar(
            text: state.message,
            color: state.isError ? KlmColors.errorRed : Colors.green,
          );
        }
      },
      builder: (context, state) {
        if (state is ChatStateError) {
          return KlmErrorWidget(
            errorMessage: state.message,
            onRetry: widget.onRetry,
          );
        }

        if (state is! ChatStateBase) return const SizedBox();

        final data = state.data;
        return FocusDetector(
          key: Key('focus_detector_${data.chatId}'),
          onForegroundGained: () => _onResume(data.chatId),
          onForegroundLost: _onPause,
          onVisibilityGained: () => _onResume(data.chatId),
          onVisibilityLost: _onPause,
          child: Column(
            children: [
              Expanded(
                child: ColoredBox(
                  color: Colors.blue.shade100,
                  child: data.isLoading && data.messages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : data.messages.isEmpty
                      ? const Center(
                          child: _TechMessage(
                            key: Key('no_messages_widget'),
                            text: '\nNo messages here yet...\n\nWrite something\n',
                          ),
                        )
                      : ListView.builder(
                          key: Key('chat_scroll_view_${data.chatId}'),
                          controller: widget.scrollController,
                          padding: EdgeInsets.only(
                            bottom: 4,
                            top: data.isAllMessagesLoaded ? 4 : 30,
                          ),
                          reverse: true,
                          itemCount: data.messages.length,
                          itemBuilder: (context, i) => VisibilityDetector(
                            /// to check visibility on every messagesList changes
                            /// (like the change of some fromCache statuses)
                            key: Key(
                              'visibility_detector_$i-${DateTime.now().millisecondsSinceEpoch}',
                            ),
                            onVisibilityChanged: (info) =>
                                _onVisibilityChanged(info, data.messages[i]),
                            child: _MessageWidget(
                              key: Key('message_${data.messages[i].id}'),
                              message: data.messages[i],
                              user: data.otherUser ?? User.loading(),
                            ),
                          ),
                        ),
                ),
              ),
              _ChatBottom(
                onSend: (message) {
                  widget.scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                  _chatBloc.add(
                    ChatEventSendMessage(
                      message: message,
                      otherUserId: data.otherUser!.id,
                    ),
                  );
                },
                isLoading: data.isLoading,
                key: const Key('chat_bottom'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onVisibilityChanged(VisibilityInfo info, Message message) {
    if (_chatBloc.isClosed) return;

    final isVisible = info.visibleFraction > 0.6;
    if (!message.isRead &&
        !message.isCurrentUser &&
        !message.fromCache &&
        isVisible) {
      _chatBloc.add(ChatEventReadMessagesBeforeTime(time: message.createdAt));
    }
    if (message.fromCache) {
      // print('MyLog2 visibleMessageFromCache: ${data.messages[i].message}');
      _chatBloc.add(ChatEventLoadMore(cachedMessageId: message.id));
    }
  }

  /// listeners
  void _onScrollListener() {
    if (!widget.scrollController.hasClients || !_isScreenActive) return;

    if (widget.scrollController.offset >
        widget.scrollController.position.maxScrollExtent - 300) {
      _chatBloc.add(const ChatEventLoadMore(cachedMessageId: null));
    }
  }

  // void _maintainScrollPos() {
  //   if (!widget.scrollController.hasClients ||
  //       widget.scrollController.offset == 0 ||
  //       _keys.isEmpty)
  //     return;
  //
  //   double currentOffset = widget.scrollController.offset;
  //   widget.scrollController.jumpTo(currentOffset + 45);
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     /// here new keys is already added
  //     if (_keys.isEmpty) return;
  //     final newMessageHeight =
  //         (_keys.values.first.$1.currentContext!.findRenderObject() as RenderBox)
  //             .size
  //             .height;
  //     if (newMessageHeight != 45) {
  //       widget.scrollController.jumpTo(currentOffset + newMessageHeight);
  //     }
  //   });
  // }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (oldState, newState) {
        if (newState is! ChatStateBase) return false;

        if (oldState is! ChatStateBase) return true;

        return oldState.data.otherUser != newState.data.otherUser ||
            oldState.data.isLoading != newState.data.isLoading ||
            oldState.data.isConnected != newState.data.isConnected;
      },
      builder: (context, state) {
        if (state is! ChatStateBase) return const SizedBox();

        final data = state.data;
        return AppBar(
          key: Key('chat_app_bar_${data.otherUser?.id}'),
          leading: const KlmBackButton(),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 0,
          title: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: data.otherUser == null
                ? null
                : () {
                    AppNavigator.withKeyOf(
                      context,
                      mainNavigatorKey,
                    )!.push(UserPage(userId: data.otherUser!.id));
                  },
            child: Skeletonizer(
              enabled: data.otherUser == null,
              child: Row(
                children: [
                  UserImage(size: 40, url: data.otherUser?.profileImage),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.otherUser?.username ?? '-------',
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            height: 1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (data.isLoading || !data.isConnected)
                          Text(
                            !data.isConnected
                                ? 'Connecting..'
                                : data.isLoading
                                ? 'Updating..'
                                : '',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
