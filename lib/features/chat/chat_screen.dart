import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';
import 'package:kepleomax/core/presentation/klm_textfield.dart';
import 'package:kepleomax/core/presentation/user_image.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _AppBar(),
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.blue.shade100,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              reverse: true,
              child: Column(
                children: [
                  _DateWidget(),
                  _MessageWidget(
                    message: Message(
                      user: User.loading(),
                      message: "Hi how are you",
                      createdAt: 1763113578000,
                      editedAt: null,
                    ),
                  ),
                  _MessageWidget(
                    message: Message(
                      user: AuthScope.userOf(context),
                      message:
                          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                      createdAt: 1763113578000,
                      editedAt: null,
                    ),
                  ),
                  _MessageWidget(
                    message: Message(
                      user: User.loading(),
                      message: "It's so amazing!",
                      createdAt: 1763113578000,
                      editedAt: null,
                    ),
                  ),
                  _DateWidget(),
                  _MessageWidget(
                    message: Message(
                      user: User.loading(),
                      message: "Hi how are you",
                      createdAt: 1763113578000,
                      editedAt: null,
                    ),
                  ),
                  _MessageWidget(
                    message: Message(
                      user: AuthScope.userOf(context),
                      message:
                          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                      createdAt: 1763113578000,
                      editedAt: null,
                    ),
                  ),
                  _MessageWidget(
                    message: Message(
                      user: User.loading(),
                      message: "It's so amazing!",
                      createdAt: 1763113578000,
                      editedAt: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _Bottom(),
      ],
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
  const _Bottom({super.key});

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
            IconButton(
              onPressed: () {},
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
  const _MessageWidget({required this.message, super.key});

  final Message message;

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
            UserImage(size: 35, url: message.user.profileImage),
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
                  '${message.message}  9:07 AM',
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
                        '9:07 AM',
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
  const _AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: KlmBackButton(),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      title: Row(
        children: [
          UserImage(size: 40, url: ''),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Username',
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
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
