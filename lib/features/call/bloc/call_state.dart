import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/user.dart';

part 'call_state.freezed.dart';

abstract class CallState {}

@freezed
abstract class CallStateBase with _$CallStateBase implements CallState {
  const factory CallStateBase({required CallData data}) = _CallStateBase;

  factory CallStateBase.initial() => CallStateBase(data: CallData.initial());
}

@freezed
abstract class CallStateOpenPage with _$CallStateOpenPage implements CallState {
  const factory CallStateOpenPage({required User otherUser}) = _CallStateOpenPage;
}

@freezed
abstract class CallStateMessage with _$CallStateMessage implements CallState {
  const factory CallStateMessage({
    required String message,
    @Default(false) bool isError,
  }) = _CallStateMessage;
}

@freezed
abstract class CallData with _$CallData implements CallState {
  const factory CallData({
    required User otherUser,
    @Default(RTCPeerConnectionState.RTCPeerConnectionStateDisconnected)
    RTCPeerConnectionState connectionState,
    RTCVideoRenderer? localRenderer,
    RTCVideoRenderer? remoteRenderer,
    @Default(false) bool isCallAccepted,
  }) = _CallData;

  factory CallData.initial() => CallData(
    otherUser: User.loading(),
    connectionState: RTCPeerConnectionState.RTCPeerConnectionStateClosed,
  );
}
