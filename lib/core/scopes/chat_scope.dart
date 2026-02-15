import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:kepleomax/core/data/connection_repository.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/notifications/notifications_service.dart';
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
  late final ConnectionRepository _repository;

  /// callbacks
  @override
  void initState() {
    _repository = Dependencies.of(context).connectionRepository;
    _repository.initSocket();
    NotificationService.instance.init().ignore();
    super.initState();
  }

  @override
  void dispose() {
    _repository.disconnect();
    super.dispose();
  }

  void _onResume(ChatsState state) {
    if (!_isScreenInited) {
      _isScreenInited = true;
      return;
    }
    if (state is ChatsStateBase && !state.data.isConnected) {
      print('MyLog chatScope onResume');
      Future.delayed(const Duration(seconds: 1), () {
        _repository.reconnect(onlyIfDisconnected: true);
      });
    }
  }

  /// build
  @override
  Widget build(BuildContext context) {
    /// ChatsBloc should be provided here cause it's used in bottomNavBar
    return BlocProvider(
      create: (context) => ChatsBloc(
        messengerRepository: Dependencies.of(context).messengerRepository,
        connectionRepository: Dependencies.of(context).connectionRepository,
      )..add(const ChatsEventLoadCache()),
      child: BlocBuilder<ChatsBloc, ChatsState>(
        builder: (context, state) => FocusDetector(
          onForegroundGained: () => _onResume(state),
          onVisibilityGained: () => _onResume(state),
          child: widget.child,
        ),
      ),
    );
  }
}
