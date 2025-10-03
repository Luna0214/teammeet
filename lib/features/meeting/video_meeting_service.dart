import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum CallStatus { ringing, accepted, missed, ended, none }

CallStatus stringToCallStatus(String status) {
  switch (status) {
    case 'ringing':
      return CallStatus.ringing;
    case 'accepted':
      return CallStatus.accepted;
    case 'missed':
      return CallStatus.missed;
    case 'ended':
      return CallStatus.ended;
    default:
      return CallStatus.none;
  }
}

String callStatusToString(CallStatus status) {
  switch (status) {
    case CallStatus.ringing:
      return 'ringing';
    case CallStatus.accepted:
      return 'accepted';
    case CallStatus.missed:
      return 'missed';
    case CallStatus.ended:
      return 'ended';
    default:
      return 'none';
  }
}

class VideoMeetingService {
  static Future<void> startVideoCall(String roomId, String receiverUid) async {
    final callsRef = FirebaseFirestore.instance.collection('calls');
    await callsRef.add({
      'roomId': roomId,
      'callerUid': FirebaseAuth.instance.currentUser?.uid,
      'calleeUid': receiverUid,
      'status': callStatusToString(CallStatus.ringing),
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> acceptVideoCall(String callId) async {
    final callsRef = FirebaseFirestore.instance.collection('calls').doc(callId);
    await callsRef.update({
      'status': callStatusToString(CallStatus.accepted),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> missedVideoCall(String callId) async {
    final callsRef = FirebaseFirestore.instance.collection('calls').doc(callId);
    await callsRef.update({
      'status': callStatusToString(CallStatus.missed),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> endVideoCall(String callId) async {
    final callsRef = FirebaseFirestore.instance.collection('calls').doc(callId);
    await callsRef.update({
      'status': callStatusToString(CallStatus.ended),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
