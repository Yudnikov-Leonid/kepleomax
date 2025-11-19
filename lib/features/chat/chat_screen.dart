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
    print('chatScreen initState');
    _chatBloc = context.read<ChatBloc>()
      ..add(ChatEventLoad(chatId: widget.chatId, otherUser: widget.otherUser));
    super.initState();
  }

  @override
  void dispose() {
    print('chatScreen dispose');
    _scrollController.dispose();
    //_chatBloc.add(const ChatEventClear());
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
        floatingActionButton: _ReadButton(scrollController: _scrollController),
        appBar: _AppBar(key: Key('chat_appbar')),
        body: _Body(
          bloc: _chatBloc,
          scrollController: _scrollController,
          key: Key('chat_body'),
        ),
      ),
    );
  }
}

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

  void _onResume(int chatId) {
    _isScreenActive = true;
    NotificationService.instance.blockNotificationsFromChat(chatId);
    _onScrollListener();
  }

  void _onPause() {
    _isScreenActive = false;
    NotificationService.instance.enableAllNotifications();
  }

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

  void _maintainScroll() {
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
      print('newMessageHeight: $newMessageHeight, message: ${_keys[0].$2}');
      if (newMessageHeight != 45) {
        widget._scrollController.jumpTo(currentOffset + newMessageHeight);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      // buildWhen: (oldState, newState) {
      //
      //   return oldState != newState;
      // },
      builder: (context, state) {
        if (state is ChatStateError) {
          return Center(child: Text('error: ${state.message}'));
        }

        if (state is! ChatStateBase) return SizedBox();

        final data = state.data;

        /// not != but +1 cause it prevents scrolling on paging
        if (_keys.isNotEmpty && _keys.length + 1 == data.messages.length) {
          /// if length of messages changes, need to maintain scroll
          _maintainScroll();
        }
        _keys.clear();
        _keys.addAll(data.messages.map((e) => (GlobalKey(), e)));
        if (data.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            /// to read all new messages
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
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          key: Key('chat_scroll_view_${data.chatId}'),
                          controller: widget._scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          reverse: true,
                          child: Column(
                            children: [
                              if (!data.isAllMessagesLoaded)
                                SizedBox(height: 20),
                              const SizedBox(width: double.infinity),
                              //_DateWidget(),

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
                key: Key('chat_bottom'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DateWidget extends StatelessWidget {
  const _DateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      margin: const EdgeInsets.only(bottom: 6, top: 6),
      child: Text(
        'February 19',
        style: context.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Bottom extends StatefulWidget {
  const _Bottom({required ValueChanged<String>? onSend, super.key})
    : _onSend = onSend;

  final ValueChanged<String>? _onSend;

  @override
  State<_Bottom> createState() => _BottomState();
}

class _BottomState extends State<_Bottom> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: context.screenSize.width,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: KlmTextField(
                controller: _controller,
                hint: 'Message',
                onChanged: (newText) {},
                multiline: true,
                maxLength: 4000,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: widget._onSend == null
                  ? null
                  : () {
                      if (_controller.text.isEmpty) return;
                      widget._onSend!(_controller.text.trim());
                      _controller.clear();
                      setState(() {});
                    },
              style: IconButton.styleFrom(backgroundColor: KlmColors.primaryColor),
              icon: Transform.rotate(
                angle: math.pi / 2,
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageWidget extends StatelessWidget {
  const _MessageWidget({required this.message, required this.user, super.key});

  final Message message;
  final User user;

  bool get _isCurrent => message.user.isCurrent;

  @override
  Widget build(BuildContext context) {
    if (message.id == -2) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        width: double.infinity,
        height: 20,
        color: Colors.grey.shade100,
        child: Center(
          child: Text(
            'Unread Messages',
            style: context.textTheme.bodyMedium?.copyWith(
              color: KlmColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          if (_isCurrent)
            const Expanded(child: SizedBox())
          else ...[
            InkWell(
              onTap: () {
                AppNavigator.withKeyOf(
                  context,
                  mainNavigatorKey,
                )!.push(UserPage(userId: user.id));
              },
              child: UserImage(size: 35, url: user.profileImage),
            ),
            const SizedBox(width: 10),
          ],
          Container(
            constraints: BoxConstraints(maxWidth: context.screenSize.width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isCurrent ? Color.fromARGB(255, 213, 255, 255) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Text(
                  message.message,
                  style: context.textTheme.bodyMedium?.copyWith(fontSize: 15),
                ),
                Text(
                  '${message.message}${_isCurrent ? '    ' : '  '}${ParseTime.unixTimeToTime(message.createdAt)}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    color: Colors.transparent,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      Text(
                        ParseTime.unixTimeToTime(message.createdAt),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: _isCurrent ? KlmColors.readMessage : Colors.grey,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (_isCurrent)
                        Icon(
                          message.isRead ? Icons.check_box : Icons.check,
                          size: 14,
                          color: KlmColors.readMessage,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!_isCurrent) const Expanded(child: SizedBox()),
        ],
      ),
    );
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
        if (state is! ChatStateBase) return SizedBox();

        final data = state.data;
        final isLoading = data.isLoading || data.otherUser == null;

        return AppBar(
          leading: KlmBackButton(),
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
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       user.username,
                  //       style: context.textTheme.bodyLarge?.copyWith(
                  //         fontWeight: FontWeight.w700,
                  //         fontSize: 20,
                  //       ),
                  //     ),
                  //     Text(
                  //       'Last seen today at 10:40 AM',
                  //       style: context.textTheme.bodyLarge?.copyWith(
                  //         color: Colors.grey,
                  //         fontSize: 14,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ReadButton extends StatefulWidget {
  const _ReadButton({required ScrollController scrollController, super.key})
    : _scrollController = scrollController;

  final ScrollController _scrollController;

  @override
  State<_ReadButton> createState() => _ReadButtonState();
}

class _ReadButtonState extends State<_ReadButton> {
  static const _offsetToShow = 100;
  double _lastPosition = 0;

  void _onScrollListener() {
    if (_lastPosition < _offsetToShow &&
        widget._scrollController.offset > _offsetToShow) {
      setState(() {});
    } else if (_lastPosition > _offsetToShow &&
        widget._scrollController.offset < _offsetToShow) {
      setState(() {});
    }
    _lastPosition = widget._scrollController.offset;
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is! ChatStateBase) return SizedBox();

        final data = state.data;
        if (state.data.messages.isEmpty) return SizedBox();
        final allMessagesIsRead =
            data.messages.first.user.isCurrent || data.messages.first.isRead;
        final isScrolledUp = widget._scrollController.positions.length == 1
            ? widget._scrollController.offset > _offsetToShow
            : false;
        if (allMessagesIsRead && !isScrolledUp) return SizedBox();
        return Padding(
          padding: const EdgeInsets.only(bottom: 75),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                shape: const CircleBorder(),
                elevation: 1,
                backgroundColor: Colors.white,
                isExtended: true,
                child: Transform.rotate(
                  angle: 270 * math.pi / 180,
                  child: Icon(Icons.arrow_back_ios_new, color: Colors.black),
                ),
                onPressed: () {
                  widget._scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                  if (!allMessagesIsRead) {
                    context.read<ChatBloc>().add(const ChatEventReadAllMessages());
                  }
                },
              ),
              if (!allMessagesIsRead)
                Positioned(
                  top: -14,
                  child: Container(
                    width: 35,
                    decoration: BoxDecoration(
                      color: KlmColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Center(
                      child: Text(
                        data.messages.where((e) => !e.isRead).length.toString(),
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
