import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/core/presentation/klm_textfield.dart';
import 'package:kepleomax/core/presentation/parse_time.dart';
import 'package:kepleomax/core/presentation/user_image.dart';
import 'package:kepleomax/features/chat/bloc/chat_bloc.dart';
import 'package:kepleomax/features/chat/bloc/chat_state.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({required this.chat, super.key});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _AppBar(user: chat.otherUser, key: Key('chat_appbar'),),
      body: _Body(chat: chat, key: Key('chat_body'),),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required Chat chat, super.key}) : _chat = chat;

  final Chat _chat;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  void initState() {
    context.read<ChatBloc>().add(
      ChatEventLoad(chatId: widget._chat.id, otherUserId: widget._chat.otherUser.id),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatStateError) {
          return Center(child: Text('error: ${state.message}'));
        }

        if (state is! ChatStateBase) return SizedBox();

        final data = state.data;
        return Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.blue.shade100,
                child: data.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        reverse: true,
                        child: Column(
                          children: [
                            const SizedBox(width: double.infinity),
                            _DateWidget(),

                            /// TODO is it good to call reverse here?
                            ...data.messages.reversed.map(
                              (message) => _MessageWidget(
                                message: message,
                                key: Key('message_${message.id}'),
                                user: widget._chat.otherUser,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            _Bottom(
              onSend: (message) {
                context.read<ChatBloc>().add(
                  ChatEventSendMessage(
                    message: message,
                    otherUserId: widget._chat.otherUser.id,
                  ),
                );
              },
              key: Key('chat_bottom'),
            ),
          ],
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
                  '${message.message}${_isCurrent ? '    ' : '   '}${ParseTime.unixTimeToTime(message.createdAt)}',
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
                        Icon(Icons.check, size: 14, color: KlmColors.readMessage),
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
  const _AppBar({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: KlmBackButton(),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      title: InkWell(
        onTap: () {
          AppNavigator.withKeyOf(
            context,
            mainNavigatorKey,
          )!.push(UserPage(userId: user.id));
        },
        child: Row(
          children: [
            UserImage(size: 40, url: user.profileImage),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.username,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Last seen today at 10:40 AM',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
