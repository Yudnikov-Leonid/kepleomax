import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/notifications/notifications_service.dart';
import 'package:kepleomax/core/presentation/app_bar_loading_action.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/core/presentation/klm_error_widget.dart';
import 'package:kepleomax/core/presentation/klm_textfield.dart';
import 'package:kepleomax/core/presentation/parse_time.dart';
import 'package:kepleomax/core/presentation/user_image.dart';
import 'package:kepleomax/features/chat/bloc/chat_bloc.dart';
import 'package:kepleomax/features/chat/bloc/chat_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
    _chatBloc = context.read<ChatBloc>()
      ..add(ChatEventLoad(chatId: widget.chatId, otherUser: widget.otherUser));
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: _ReadButton(
        scrollController: _scrollController,
        key: const Key('chat_read_button'),
      ),
      appBar: const _AppBar(key: Key('chat_appbar')),
      body: _Body(
        chatBloc: _chatBloc,
        scrollController: _scrollController,
        onRetry: () {
          _chatBloc.add(
            ChatEventLoad(chatId: widget.chatId, otherUser: widget.otherUser),
          );
        },
        key: const Key('chat_body'),
      ),
    );
  }
}

/// body
class _Body extends StatefulWidget {
  const _Body({
    required this.scrollController,
    required this.chatBloc,
    required this.onRetry,
    super.key,
  });

  final ScrollController scrollController;
  final ChatBloc chatBloc;
  final VoidCallback onRetry;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  /// int - messageId
  final Map<int, (GlobalKey, Message)> _keys = {};
  final Set<Message> _visibleMessages = {};
  bool _isScreenActive = false;

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

        /// not != but +1 cause it prevents scrolling on paging
        /// TODO almost, except case when there's one new message
        if (_keys.isNotEmpty && _keys.length + 1 == data.messages.length) {
          /// if length of messages changes, need to maintain scrollPosition
          _maintainScrollPos();
        }
        final oldKeys = Map.of(_keys);
        _keys.clear();
        for (final message in data.messages) {
          _keys[message.id] = (oldKeys[message.id]?.$1 ?? GlobalKey(), message);
        }
        if (data.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            /// to read new messages
            _onScrollListener();
          });
        }
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
                            top: data.isAllMessagesLoaded ? 4 : 20,
                          ),
                          reverse: true,
                          itemCount: data.messages.length,
                          itemBuilder: (context, i) => data.otherUser == null
                              ? const SizedBox()
                              : _MessageWidget(
                                  key: _keys[data.messages[i].id]!.$1,
                                  message: data.messages[i],
                                  user: data.otherUser!,
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
                  context.read<ChatBloc>().add(
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

  /// listeners
  void _onScrollListener() {
    if (!widget.scrollController.hasClients || !_isScreenActive) return;

    if (widget.scrollController.offset >
        widget.scrollController.position.maxScrollExtent - 100) {
      widget.chatBloc.add(const ChatEventLoadMore());
    }

    if (_keys.isEmpty) return;

    List<Message> newVisibleMessages = [];
    double heightOffset = 0;
    for (int i = 0; i < _keys.length; i++) {
      final el = _keys.values.elementAt(i); // $1 - globalKey, $2 - message
      if (el.$2.user.isCurrent || el.$2.isRead) break;

      final renderBox = el.$1.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;
      double widgetTop = renderBox.size.height;

      double viewportTop = widget.scrollController.position.pixels;

      widgetTop += heightOffset;
      heightOffset += renderBox.size.height;

      if (widgetTop >= viewportTop + 20) {
        final isAdded = _visibleMessages.add(el.$2);
        if (isAdded) {
          newVisibleMessages.add(el.$2);
          //print('newVisibleMessage: ${_keys[i].$2.message}');
        }
      } else {
        final isRemoved = _visibleMessages.remove(el.$2);
        if (isRemoved) {
          // print('deletedVisibleMessage: ${_keys[i].$2}');
        }
      }
    }
    if (newVisibleMessages.isNotEmpty) {
      context.read<ChatBloc>().add(
        ChatEventReadMessagesBeforeTime(time: newVisibleMessages[0].createdAt),
      );
    }
  }

  void _maintainScrollPos() {
    if (!widget.scrollController.hasClients ||
        widget.scrollController.offset == 0 ||
        _keys.isEmpty)
      return;

    double currentOffset = widget.scrollController.offset;
    widget.scrollController.jumpTo(currentOffset + 45);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// here new keys is already added
      if (_keys.isEmpty) return;
      final newMessageHeight =
          (_keys.values.first.$1.currentContext!.findRenderObject() as RenderBox)
              .size
              .height;
      if (newMessageHeight != 45) {
        widget.scrollController.jumpTo(currentOffset + newMessageHeight);
      }
    });
  }
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
            oldState.data.isLoading != newState.data.isLoading;
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
          actions: !data.isLoading ? null : [const AppBarLoadingAction()],
          title: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: data.isLoading || data.otherUser == null
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
                    child: Text(
                      data.otherUser?.username ?? '-------',
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
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
