import 'package:flutter_webrtc/flutter_webrtc.dart';

abstract class PeerConnectionController {
  Future<void> init({
    required void Function(RTCTrackEvent) onTrack,
    required void Function(RTCIceCandidate) onIceCandidate,
  });

  Future<RTCSessionDescription> createOffer();

  Future<RTCSessionDescription> createAnswer();

  Future<void> addIceCandidate(RTCIceCandidate candidate);

  Future<void> setLocalDescription(RTCSessionDescription desc);

  Future<void> setRemoteDescription(RTCSessionDescription desc);

  Future<void> addTracks(MediaStream mediaStream);

  Future<void> dispose();

  bool get isActive;
}

class PeerConnectionControllerImpl implements PeerConnectionController {
  RTCPeerConnection? _peerConnection;

  @override
  Future<void> init({
    required void Function(RTCTrackEvent) onTrack,
    required void Function(RTCIceCandidate) onIceCandidate,
  }) async {
    if (_peerConnection != null) {
      await dispose();
    }

    final config = {
      'sdpSemantics': 'unified-plan',
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };
    _peerConnection = await createPeerConnection(config);

    _peerConnection!.onTrack = (track) async {
      print('KlmLog newTrack: ${track.track.kind}');
      onTrack(track);
    };
    _peerConnection!.onIceCandidate = onIceCandidate;

    /// DEBUG
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      // _data = _data.copyWith(connectionState: state);
      // add(const _CallEventEmit());
      print('KlmLog RTCPeerConnectionState: $state');

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _peerConnection!.getStats().then((stats) {
          stats.forEach((report) {
            print('KlmLog failed, type: ${report.type}, values: ${report.values}');
          });
        });
      }
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      print('KlmLog RTCIceConnectionState: $state');
    };
  }

  @override
  Future<RTCSessionDescription> createOffer() => _peerConnection!.createOffer();

  @override
  Future<void> addTracks(MediaStream mediaStream) async {
    for (final track in mediaStream.getTracks()) {
      await _peerConnection!.addTrack(track, mediaStream);
    }
  }

  @override
  Future<void> dispose() async {
    await _peerConnection!.close();
    await _peerConnection!.dispose();
    _peerConnection = null;
  }

  @override
  Future<void> addIceCandidate(RTCIceCandidate candidate) =>
      _peerConnection!.addCandidate(candidate);

  @override
  Future<RTCSessionDescription> createAnswer() => _peerConnection!.createAnswer();

  @override
  Future<void> setLocalDescription(RTCSessionDescription desc)  =>
      _peerConnection!.setLocalDescription(desc);

  @override
  Future<void> setRemoteDescription(RTCSessionDescription desc)  =>
      _peerConnection!.setRemoteDescription(desc);

  @override
  bool get isActive => _peerConnection != null;
}
