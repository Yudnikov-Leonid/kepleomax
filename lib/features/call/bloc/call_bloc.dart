import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/websockets/webrtc_web_socket.dart';
import 'package:kepleomax/features/call/bloc/call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc({
    required WebRtcWebSocket webRtcWebSocket,
    required UserRepository userRepository,
  }) : _userRepository = userRepository,
       _webRtcWebSocket = webRtcWebSocket,
       super(CallStateBase.initial()) {
    on<CallEvent>(
      (event, emit) => switch (event) {
        final _CallEventOpenCallPage event => _onOpenCallPage(event, emit),
        final CallEventAcceptCall event => _onAcceptCall(event, emit),
        final CallEventCall event => _onCall(event, emit),
        final CallEventEndCall event => _onEndCall(event, emit),

        _ => null,
      },
      transformer: sequential(),
    );
    on<CallEventInit>(_onInit);
    on<CallEventFlipCamera>(_onFlipCamera);
    on<_CallEventEmit>(_onEmit);
    // on<_CallEventEmitStatus>(_onEmitStatus);

    _offersSub = _webRtcWebSocket.offersStream.listen((offer) async {
      print('KlmLog offer is received');
      _cachedOffer = offer.offer;
      add(_CallEventOpenCallPage(otherUserId: offer.otherUserId));
    });
    _answersSub = _webRtcWebSocket.answersStream.listen((answer) async {
      print('KlmLog answer is received');
      _waitAnswerTimer!.cancel();
      _waitAnswerTimer = null;
      _candidates
        ..forEach(_peerConnection!.addCandidate)
        ..clear();
      await _peerConnection!.setRemoteDescription(answer.answer);
      final renderer = await _setUpRemoteRenderer();
      _data = _data.copyWith(
        remoteRenderer: renderer,
        isCallAccepted: true,
        // status: CallStatus.accepted,
      );
      add(const _CallEventEmit());
    });
    _candidatesSub = _webRtcWebSocket.candidatesStream.listen((candidate) async {
      if (_peerConnection != null) {
        await _peerConnection!.addCandidate(candidate.candidate);
      } else {
        _candidates.add(candidate.candidate);
      }
      // print('KlmLog iceCandidate is received');
    });
    _endCallSub = _webRtcWebSocket.endCallStream.listen((_) {
      add(const CallEventEndCall(notifyOtherUser: false));
    });

    FlutterCallkitIncoming.activeCalls().then((calls) {
      if (calls is List && calls.isNotEmpty) {
        if (calls[0]['isAccepted'] == true) {
          _openCallFromNotification(calls[0]['extra'] as Map<dynamic, dynamic>);
        }
      }
    });

    _incomingCallsSub = FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) return;

      switch (event.event) {
        case Event.actionCallAccept:
          _openCallFromNotification(event.body['extra'] as Map<dynamic, dynamic>);
          break;

        case Event.actionCallDecline:
          add(const CallEventEndCall(notifyOtherUser: true));
          break;

        case Event.actionCallEnded:
          break;

        case Event.actionCallTimeout:
          break;

        default:
          break;
      }
    });
  }

  void _openCallFromNotification(Map<dynamic, dynamic> extra) {
    print('KlmLog openCallFromNotification');
    _cachedOffer = RTCSessionDescription(
      extra['offer_sdp'] as String?,
      extra['offer_type'] as String?,
    );
    add(_CallEventOpenCallPage(otherUserId: extra['other_user_id'] as int));
    add(const CallEventAcceptCall());
  }

  final WebRtcWebSocket _webRtcWebSocket;
  final UserRepository _userRepository;

  late StreamSubscription<void> _offersSub;
  late StreamSubscription<void> _answersSub;
  late StreamSubscription<void> _candidatesSub;
  late StreamSubscription<void> _endCallSub;
  late StreamSubscription<void> _incomingCallsSub;

  final _candidates = <RTCIceCandidate>[];
  final _tracks = <RTCTrackEvent>[];
  RTCSessionDescription? _cachedOffer;
  RTCPeerConnection? _peerConnection;
  late CallData _data = CallData.initial();

  Timer? _waitAnswerTimer;

  Future<void> _createPeerConnection() async {
    final config = {
      'sdpSemantics': 'unified-plan',
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };
    _peerConnection = await createPeerConnection(config);

    _peerConnection!.onTrack = (event) async {
      print(
        'KlmLog newTrack: ${event.track.kind}, event.streams[0].getVideoTracks().isNotEmpty: ${event.streams[0].getVideoTracks().isNotEmpty}',
      );
      _tracks.add(event);
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      _data = _data.copyWith(connectionState: state);
      add(const _CallEventEmit());
      print('KlmLog RTCPeerConnectionState: $state');

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _peerConnection!.getStats().then((stats) {
          stats.forEach((report) {
            // if (report.type == 'candidate-pair' &&
            //     report.values['state'] == 'failed') {
            print('KlmLog failed, type: ${report.type}, values: ${report.values}');
            // }
          });
        });
      }
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      print('KlmLog RTCIceConnectionState: $state');
    };
  }

  Future<void> _onInit(CallEventInit event, Emitter<CallState> emit) async {
    _data = _data.copyWith(otherUser: event.otherUser);
    emit(CallStateBase(data: _data));

    if (event.doCall) add(CallEventCall(otherUser: event.otherUser));
  }

  Future<RTCVideoRenderer> _setUpLocalRenderer(int otherUserId) async {
    _peerConnection!.onIceCandidate = (candidate) {
      _webRtcWebSocket.sendIceCandidate(candidate, otherUserId);
    };

    final localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'facingMode': 'environment', // or user
      },
    });
    localStream.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, localStream);
    });

    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    renderer.srcObject = localStream;

    return renderer;
  }

  Future<void> _onCall(CallEventCall event, Emitter<CallState> emit) async {
    await _createPeerConnection();

    final localRenderer = await _setUpLocalRenderer(event.otherUser.id);

    final offer = await _peerConnection!.createOffer();
    _webRtcWebSocket.sendOffer(offer, _data.otherUser.id);
    await _peerConnection!.setLocalDescription(offer);

    _data = _data.copyWith(
      isCallAccepted: true,
      localRenderer: localRenderer,
      // status: CallStatus.waitingForResponse,
    );
    emit(CallStateBase(data: _data));

    _waitAnswerTimer = Timer(AppConstants.callingTimeout, () {
      print('KlmLog cancel due to timeout');
      add(const CallEventEndCall(notifyOtherUser: true));
    });
  }

  Future<void> _onAcceptCall(
    CallEventAcceptCall event,
    Emitter<CallState> emit,
  ) async {
    await _createPeerConnection();

    if (_cachedOffer == null) throw Exception('_cachedOffer == null');
    await _peerConnection!.setRemoteDescription(_cachedOffer!);
    _cachedOffer = null;

    print('KlmLog apply iceCandidates: ${_candidates.length}');
    _candidates
      ..forEach(_peerConnection!.addCandidate)
      ..clear();

    final localRenderer = await _setUpLocalRenderer(_data.otherUser.id);

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    _webRtcWebSocket.sendAnswer(answer, _data.otherUser.id);

    final remoteRenderer = await _setUpRemoteRenderer();

    _data = _data.copyWith(
      isCallAccepted: true,
      localRenderer: localRenderer,
      remoteRenderer: remoteRenderer,
    );
    emit(CallStateBase(data: _data));

    unawaited(
      FlutterCallkitIncoming.hideCallkitIncoming(
        CallKitParams(id: _data.otherUser.id.toString()),
      ),
    );
  }

  Future<RTCVideoRenderer> _setUpRemoteRenderer() async {
    final remoteRenderer = RTCVideoRenderer();
    await remoteRenderer.initialize();

    _tracks.forEach((event) {
      if (event.track.kind == 'video') {
        /// TODO memory leak ?
        remoteRenderer.srcObject = event.streams[0];
        add(const _CallEventEmit());
      }
    });

    return remoteRenderer;
  }

  void _onFlipCamera(CallEventFlipCamera event, Emitter<CallState> emit) {
    Helper.switchCamera(_data.localRenderer!.srcObject!.getVideoTracks()[0]);
  }

  void _onEmit(_CallEventEmit event, Emitter<CallState> emit) {
    emit(CallStateBase(data: _data));
  }

  Future<void> _onOpenCallPage(
    _CallEventOpenCallPage event,
    Emitter<CallState> emit,
  ) async {
    /// TODO make getUser from cache
    final otherUser = await _userRepository.getUser(userId: event.otherUserId);
    emit(CallStateOpenPage(otherUser: otherUser));
    _data = _data.copyWith(
      otherUser: otherUser,
      isCallAccepted: false,
      // status: CallStatus.waitingForYourResponse,
    );
    emit(CallStateBase(data: _data));
  }

  void _onEndCall(CallEventEndCall event, Emitter<CallState> emit) {
    if (event.notifyOtherUser && _data.otherUser.id != User.loading().id) {
      _webRtcWebSocket.endCall(_data.otherUser.id);
    }

    print('KlmLog endCall');
    _data.localRenderer?.srcObject?.dispose();
    _data.localRenderer?.dispose();
    _data.remoteRenderer?.srcObject?.dispose();
    _data.remoteRenderer?.dispose();
    _data.localRenderer?.srcObject?.getTracks().forEach((track) {
      track.stop();
    });
    _data.remoteRenderer?.srcObject?.getTracks().forEach((track) {
      track.stop();
    });
    _peerConnection?.dispose();
    _peerConnection = null;

    _cachedOffer = null;
    _tracks.clear();
    _candidates.clear();
    _waitAnswerTimer?.cancel();
    _waitAnswerTimer = null;

    FlutterCallkitIncoming.endCall(_data.otherUser.id.toString());
    emit(const CallStateExit());
    emit(CallStateBase(data: _data));
    _data = CallData.initial();
  }

  @override
  Future<void> close() {
    _offersSub.cancel();
    _answersSub.cancel();
    _candidatesSub.cancel();
    _endCallSub.cancel();
    _incomingCallsSub.cancel();

    return super.close();
  }
}

@immutable
abstract class CallEvent {}

class CallEventInit implements CallEvent {
  const CallEventInit({required this.otherUser, required this.doCall});

  final User otherUser;
  final bool doCall;
}

class CallEventCall implements CallEvent {
  const CallEventCall({required this.otherUser});

  final User otherUser;
}

class CallEventAcceptCall implements CallEvent {
  const CallEventAcceptCall();
}

class CallEventFlipCamera implements CallEvent {
  const CallEventFlipCamera();
}

class CallEventEndCall implements CallEvent {
  const CallEventEndCall({required this.notifyOtherUser});

  final bool notifyOtherUser;
}

class _CallEventEmit implements CallEvent {
  const _CallEventEmit();
}

class _CallEventOpenCallPage implements CallEvent {
  const _CallEventOpenCallPage({required this.otherUserId});

  final int otherUserId;
}

// class _CallEventEmitStatus implements CallEvent {
//   _CallEventEmitStatus({required this.status});
//
//   final CallStatus status;
// }
