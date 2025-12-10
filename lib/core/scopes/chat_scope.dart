import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/notifications/notifications_service.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';
import 'package:kepleomax/features/chat/bloc/chat_bloc.dart';
import 'package:kepleomax/features/chats/bloc/chats_bloc.dart';
import 'package:kepleomax/features/chats/bloc/chats_state.dart';

class ChatScope extends StatefulWidget {
  const ChatScope({required this.child, super.key});

  final Widget child;

  @override
  State<ChatScope> createState() => _ChatScopeState();
}

class _ChatScopeState extends State<ChatScope> {
  bool _isScreenInited = false;

  @override
  void initState() {
    NotificationService.instance.init().ignore();
    super.initState();
  }

  void _onResume(ChatsState state, ChatsBloc bloc) {
    if (!_isScreenInited) {
      _isScreenInited = true;
      return;
    }
    if (state is ChatsStateBase && !state.data.isConnected) {
      print('MyLog chatScope onResume');
      bloc.add(const ChatsEventReconnect(onlyIfNot: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ChatsBloc(
            userId: AuthScope.userOf(context).id,
            chatsRepository: Dependencies.of(context).chatsRepository,
            messagesRepository: Dependencies.of(context).messagesRepository,
          )..add(const ChatsEventLoadCache()),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(
            chatsRepository: Dependencies.of(context).chatsRepository,
            messagesRepository: Dependencies.of(context).messagesRepository,
          ),
        ),
      ],
      child: BlocBuilder<ChatsBloc, ChatsState>(
        builder: (context, state) {
          /// ping to init
          context.read<ChatBloc>();
          final bloc = context.read<ChatsBloc>();

          return FocusDetector(
            onForegroundGained: () => _onResume(state, bloc),
            onVisibilityGained: () => _onResume(state, bloc),
            child: widget.child,
          );
        },
      ),
    );
  }
}
