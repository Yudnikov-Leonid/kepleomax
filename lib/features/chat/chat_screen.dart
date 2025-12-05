import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/notifications/notifications_service.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/core/presentation/klm_textfield.dart';
import 'package:kepleomax/core/presentation/parse_time.dart';
import 'package:kepleomax/core/presentation/user_image.dart';
import 'package:kepleomax/features/chat/bloc/chat_bloc.dart';
import 'package:kepleomax/features/chat/bloc/chat_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'widgets/bottom.dart';
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
    _chatBloc.add(const ChatEventClear());
    super.dispose();
  }

  /// build
  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatStateMessage) {
          context.showSnackBar(
            text: state.message,
            color: state.isError ? KlmColors.errorRed : Colors.green,
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        floatingActionButton: _ReadButton(
          scrollController: _scrollController,
          key: const Key('chat_read_button'),
        ),
        appBar: const _AppBar(key: Key('chat_appbar')),
        body: _Body(
          bloc: _chatBloc,
          scrollController: _scrollController,
          key: const Key('chat_body'),
        ),
      ),
    );
  }
}

/// body
class _Body extends StatefulWidget {
  const _Body({
    required ScrollController scrollController,
    required ChatBloc bloc,
    super.key,
  }) : _chatBloc = bloc,
       _scrollController = scrollController;

  final ScrollController _scrollController;
  final ChatBloc _chatBloc;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final List<(GlobalKey, Message)> _keys = [];
  final Set<Message> _visibleMessages = {};
  bool _isScreenActive = false;

  /// callbacks
  @override
  void initState() {
    widget._scrollController.addListener(_onScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    widget._scrollController.removeListener(_onScrollListener);
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
    return BlocBuilder<ChatBloc, ChatState>(
      /// don't need buildWhen
      builder: (context, state) {
        if (state is ChatStateError) {
          return Center(child: Text('error: ${state.message}'));
        }

        if (state is! ChatStateBase) return const SizedBox();

        final data = state.data;

        /// not != but +1 cause it prevents scrolling on paging
        /// TODO almost, except case when there's one new message
        if (_keys.isNotEmpty && _keys.length + 1 == data.messages.length) {
          /// if length of messages changes, need to maintain scroll
          _maintainScroll();
        }
        _keys.clear();
        _keys.addAll(data.messages.map((e) => (GlobalKey(), e)));
        if (data.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            /// to read new messages
            _onScrollListener();
          });
        }
        final keysReversed = _keys.reversed.toList();
        return FocusDetector(
          key: Key('focus_detector_${data.chatId}'),
          onForegroundGained: () => _onResume(data.chatId),
          onForegroundLost: _onPause,
          onVisibilityGained: () => _onResume(data.chatId),
          onVisibilityLost: _onPause,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.blue.shade100,
                  child: data.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          key: Key('chat_scroll_view_${data.chatId}'),
                          controller: widget._scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          reverse: true,
                          child: data.messages.isEmpty
                              ? const Center(
                                  child: _TechMessage(
                                    key: Key('no_messages_widget'),
                                    text:
                                        '\nNo messages here yet...\n\nWrite something\n',
                                  ),
                                )
                              : Column(
                                  children: [
                                    const SizedBox(width: double.infinity),
                                    if (!data.isAllMessagesLoaded)
                                      const SizedBox(height: 20),

                                    /// TODO is it good to call reverse here?
                                    ...data.messages.reversed.mapIndexed(
                                      (i, message) => _MessageWidget(
                                        key: keysReversed[i].$1,
                                        message: message,

                                        /// todo why user from data but not from message?
                                        user: data.otherUser!,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                ),
              ),
              _Bottom(
                onSend: (message) {
                  widget._scrollController.animateTo(
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
    if (!widget._scrollController.hasClients || !_isScreenActive) return;

    if (widget._scrollController.offset >
        widget._scrollController.position.maxScrollExtent - 100) {
      widget._chatBloc.add(const ChatEventLoadMore());
    }

    if (_keys.isEmpty) return;

    List<Message> newVisibleMessages = [];
    double heightOffset = 0;
    for (int i = 0; i < _keys.length; i++) {
      if (_keys[i].$2.user.isCurrent || _keys[i].$2.isRead) break;

      final renderBox = _keys[i].$1.currentContext!.findRenderObject() as RenderBox;
      double widgetTop = renderBox.size.height;

      double viewportTop = widget._scrollController.position.pixels;

      widgetTop += heightOffset;
      heightOffset += renderBox.size.height;

      if (widgetTop >= viewportTop + 20) {
        final isAdded = _visibleMessages.add(_keys[i].$2);
        if (isAdded) {
          newVisibleMessages.add(_keys[i].$2);
          //print('newVisibleMessage: ${_keys[i].$2.message}');
        }
      } else {
        final isRemoved = _visibleMessages.remove(_keys[i].$2);
        if (isRemoved) {
          // print('deletedVisibleMessage: ${_keys[i].$2}');
        }
      }
    }
    if (newVisibleMessages.isNotEmpty) {
      print('read message: ${newVisibleMessages[0].message}');

      context.read<ChatBloc>().add(
        ChatEventReadMessagesBeforeTime(time: newVisibleMessages[0].createdAt),
      );
    }
  }

  void _maintainScroll() {
    if (!widget._scrollController.hasClients) return;
    if (widget._scrollController.offset == 0 || _keys.isEmpty) return;
    double currentOffset = widget._scrollController.offset;
    widget._scrollController.jumpTo(currentOffset + 45);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// here new keys is already added
      if (_keys.isEmpty) return;
      final newMessageHeight =
          (_keys.first.$1.currentContext!.findRenderObject() as RenderBox)
              .size
              .height;
      if (newMessageHeight != 45) {
        widget._scrollController.jumpTo(currentOffset + newMessageHeight);
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
        final isLoading = data.isLoading || data.otherUser == null;

        return AppBar(
          leading: const KlmBackButton(),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 0,
          title: InkWell(
            onTap: isLoading
                ? null
                : () {
                    AppNavigator.withKeyOf(
                      context,
                      mainNavigatorKey,
                    )!.push(UserPage(userId: data.otherUser!.id));
                  },
            child: Skeletonizer(
              enabled: isLoading,
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
