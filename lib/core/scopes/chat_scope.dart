import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';
import 'package:kepleomax/features/chat/bloc/chat_bloc.dart';

class ChatScope extends StatelessWidget {
  const ChatScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatBloc>(
      create: (context) => ChatBloc(
        userId: AuthScope.userOf(context).id,
        messagesRepository: Dependencies.of(context).messagesRepository,
        chatsRepository: Dependencies.of(context).chatsRepository,
      ),
      child: Builder(
        builder: (context) {
          /// ping to init
          context.read<ChatBloc>();

          return child;
        }
      ),
    );
  }
}
