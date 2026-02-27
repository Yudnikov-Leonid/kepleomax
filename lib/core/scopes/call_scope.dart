import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/app.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/features/call/bloc/call_bloc.dart';
import 'package:kepleomax/features/call/bloc/call_state.dart';
import 'package:kepleomax/features/chats/chats_screen_navigator.dart';

class CallScope extends StatelessWidget {
  const CallScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dp = Dependencies.of(context);
        return CallBloc(
          webRtcWebSocket: dp.webRtcWebSocket,
          userRepository: dp.userRepository,
        );
      },
      child: BlocListener<CallBloc, CallState>(
        listener: (context, state) {
          if (state is CallStateOpenPage) {
            mainNavigatorGlobalKey.currentState!.push(
              CallPage(otherUser: state.otherUser, doCall: false),
            );
          }
        },
        child: child,
      ),
    );
  }
}
