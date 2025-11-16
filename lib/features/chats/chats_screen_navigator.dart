import 'package:flutter/material.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/features/chat/chat_screen.dart';
import 'package:kepleomax/features/chats/chats_screen.dart';

const chatsNavigatorKey = 'ChatsNavigator';

class ChatsNavigator extends StatelessWidget {
  const ChatsNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigator(
      initialState: [const ChatsPage()],
      navigatorKey: chatsNavigatorKey,
    );
  }
}

/// pages
final class ChatsPage extends AppPage {
  const ChatsPage()
    : super(
        name: "chats_screen",
        child: const ChatsScreen(),
        key: const ValueKey("chats_screen"),
      );
}

final class ChatPage extends AppPage {
  ChatPage({required Chat chat})
    : super(
        name: "chat_screen",
        child: ChatScreen(chat: chat),
        key: const ValueKey("chat_screen"),
      );
}
