import 'package:flutter_webrtc/flutter_webrtc.dart';

class OfferUpdate {
  const OfferUpdate({required this.fromUserId, required this.offer});

  factory OfferUpdate.fromJson(Map<String, dynamic> json) => OfferUpdate(
    fromUserId: json['from_user_id'] as int,
    offer: RTCSessionDescription(
      json['offer']['sdp'] as String?,
      json['offer']['type'] as String?,
    ),
  );

  final int fromUserId;
  final RTCSessionDescription offer;
}

class AnswerUpdate {
  const AnswerUpdate({required this.fromUserId, required this.answer});

  factory AnswerUpdate.fromJson(Map<String, dynamic> json) => AnswerUpdate(
    fromUserId: json['from_user_id'] as int,
    answer: RTCSessionDescription(
      json['answer']['sdp'] as String?,
      json['answer']['type'] as String?,
    ),
  );

  final int fromUserId;
  final RTCSessionDescription answer;
}

class CandidateUpdate {
  const CandidateUpdate({required this.fromUserId, required this.candidate});

  factory CandidateUpdate.fromJson(Map<String, dynamic> json) => CandidateUpdate(
    fromUserId: json['from_user_id'] as int,
    candidate: RTCIceCandidate(
      json['candidate']['candidate'] as String?,
      json['candidate']['sdpMid'] as String?,
      json['candidate']['sdpMLineIndex'] as int?,
    ),
  );

  final int fromUserId;
  final RTCIceCandidate candidate;
}
