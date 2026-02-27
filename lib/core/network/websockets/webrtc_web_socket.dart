import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:kepleomax/core/network/websockets/klm_web_socket.dart';
import 'package:kepleomax/core/network/websockets/models/webrtc_models.dart';

class WebRtcWebSocket {
  WebRtcWebSocket({required KlmWebSocket klmWebSocket}) : _webSocket = klmWebSocket {
    _webSocket.eventsStream.listen((event) {
      final data = event.$2;
      switch (event.$1) {
        case 'webrtc_offer':
          _offersController.add(OfferUpdate.fromJson(data as Map<String, dynamic>));

        case 'webrtc_answer':
          _answersController.add(AnswerUpdate.fromJson(data as Map<String, dynamic>));

        case 'webrtc_ice_candidate':
          _candidatesController.add(
            CandidateUpdate.fromJson(data as Map<String, dynamic>),
          );
      }
    });
  }

  final KlmWebSocket _webSocket;

  final _offersController = StreamController<OfferUpdate>.broadcast();
  final _answersController = StreamController<AnswerUpdate>.broadcast();
  final _candidatesController = StreamController<CandidateUpdate>.broadcast();

  void sendOffer(RTCSessionDescription offer, int toUserId) {
    _webSocket.emit('webrtc_send_offer', {
      'to_user_id': toUserId,
      'offer': offer.toMap(),
    });
  }

  void sendAnswer(RTCSessionDescription answer, int toUserId) {
    _webSocket.emit('webrtc_send_answer', {
      'to_user_id': toUserId,
      'answer': answer.toMap(),
    });
  }

  void sendIceCandidate(RTCIceCandidate candidate, int toUserId) {
    _webSocket.emit('webrtc_send_ice_candidate', {
      'to_user_id': toUserId,
      'candidate': candidate.toMap(),
    });
  }

  Stream<OfferUpdate> get offersStream => _offersController.stream;

  Stream<AnswerUpdate> get answersStream => _answersController.stream;

  Stream<CandidateUpdate> get candidatesStream => _candidatesController.stream;
}
