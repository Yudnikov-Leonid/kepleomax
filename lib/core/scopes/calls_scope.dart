import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:kepleomax/core/app.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/features/chats/chats_screen_navigator.dart';

class CallsScope extends StatefulWidget {
  const CallsScope({required this.child, super.key});

  final Widget child;

  @override
  State<CallsScope> createState() => _CallsScopeState();
}

class _CallsScopeState extends State<CallsScope> {
  late final StreamSubscription<void> _offersSub;
  late final StreamSubscription<void> _incomingCallsSub;

  @override
  void initState() {
    _offersSub = Dependencies.of(context).rtcWebSocket.offersStream.listen((
      offerUpdate,
    ) {
      _openCallPage({
        'other_user_id': offerUpdate.otherUserId,
        'offer_sdp': offerUpdate.offer.sdp,
        'offer_type': offerUpdate.offer.type,
      });
    });

    /// TODO make better
    _incomingCallsSub = FlutterCallkitIncoming.onEvent.listen((event) {
      if (event?.event == Event.actionCallAccept) {
        _openCallPage(event!.body['extra'] as Map<String, dynamic>);
      } else if (event?.event == Event.actionCallDecline) {
        Dependencies.of(
          context,
        ).rtcWebSocket.endCall(event!.body['extra']['other_user_id'] as int);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _offersSub.cancel();
    _incomingCallsSub.cancel();
    super.dispose();
  }

  void _onResume() {
    FlutterCallkitIncoming.activeCalls().then((calls) {
      if (calls is List && calls.isNotEmpty) {
        if (calls[0]['isAccepted'] == true) {
          _openCallPage(calls[0]['extra'] as Map<dynamic, dynamic>);
        }
      }
    });
  }

  Future<void> _openCallPage(Map<dynamic, dynamic> extra) async {
    final otherUser = await Dependencies.of(
      context,
    ).userRepository.getUser(userId: extra['other_user_id'] as int);
    mainNavigatorGlobalKey.currentState!.push(
      CallPage(
        otherUser: otherUser,
        doCall: false,
        offer: (extra['offer_sdp'] != null || extra['offer_type'] != null)
            ? RTCSessionDescription(
                extra['offer_sdp'] as String?,
                extra['offer_type'] as String?,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onForegroundGained: _onResume,
      onVisibilityGained: _onResume,
      child: widget.child,
    );
  }
}
