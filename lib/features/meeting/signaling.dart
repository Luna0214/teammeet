import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Signaling {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  String? roomId;
  String? currentRoomText;
  Function(MediaStream stream)? onAddRemoteStream;

  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ],
      },
    ],
  };

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    var stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'width': {'ideal': 640},
        'height': {'ideal': 480},
        'facingMode': 'user',
      },
    });

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  Future<String> createRoom(RTCVideoRenderer remoteRenderer) async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      DocumentReference roomRef = db.collection('rooms').doc();

      debugPrint('PeerConnection 생성 설정값: $configuration');

      peerConnection = await createPeerConnection(configuration);

      registerPeerConnectionListeners();

      localStream?.getTracks().forEach(
        (track) => peerConnection?.addTrack(track, localStream!),
      );

      // NOTE: ICE candidate 수집 및 저장
      var callerCandidatesCollection = roomRef.collection('callerCandidates');

      peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
        debugPrint('Candidate 획득: ${candidate.toMap()}');
        callerCandidatesCollection.add(candidate.toMap());
      };

      // NOTE: 방 생성
      RTCSessionDescription offer = await peerConnection!.createOffer();
      await peerConnection!.setLocalDescription(offer);

      Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};
      await roomRef.set(roomWithOffer);
      var roomId = roomRef.id;

      peerConnection?.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          debugPrint('Remote Stream 획득: ${event.streams[0]}');
          onAddRemoteStream?.call(event.streams[0]);
          remoteStream = event.streams[0];
        }
      };

      // NOTE: Remote Session Description 리스너 설정
      roomRef.snapshots().listen((snapshot) async {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data == null) return;
        if ((await peerConnection?.getRemoteDescription()) == null &&
            data['answer'] != null) {
          var answer = RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );

          await peerConnection?.setRemoteDescription(answer);
        }
      });

      // NOTE: Remote ICE candidates 리스너 설정
      roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            Map<String, dynamic> data =
                change.doc.data() as Map<String, dynamic>;
            debugPrint('새로운 Remote Candidate 획득: ${jsonEncode(data)}');

            peerConnection!.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        }
      });

      return roomId;
    } catch (e) {
      debugPrint('createRoom 오류: $e');
      return "";
    }
  }

  Future<void> joinRoom(String roomId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();
    debugPrint('Room 존재 여부: ${roomSnapshot.exists}');

    if (roomSnapshot.exists) {
      debugPrint('PeerConnection 생성 설정값: $configuration');

      peerConnection = await createPeerConnection(configuration);

      registerPeerConnectionListeners();

      localStream?.getTracks().forEach(
        (track) => peerConnection?.addTrack(track, localStream!),
      );

      // NOTE: ICE candidates 수집
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
        debugPrint('Candidate 획득: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
      };

      peerConnection?.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          debugPrint('Remote Stream 획득: ${event.streams[0]}');
          onAddRemoteStream?.call(event.streams[0]);
          remoteStream = event.streams[0];
        }
      };

      // NOTE: SFP ANSWER 생성
      var data = roomSnapshot.data() as Map<String, dynamic>;
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      var answer = await peerConnection!.createAnswer();

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp},
      };

      await roomRef.update(roomWithAnswer);

      // NOTE: Remote ICE candidates 리스너 설정
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            Map<String, dynamic> data =
                change.doc.data() as Map<String, dynamic>;
            debugPrint('새로운 Remote Candidate 획득: ${jsonEncode(data)}');
            peerConnection!.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        }
      });
    }
  }

  Future<void> hangUp(RTCVideoRenderer localVideo) async {
    List<MediaStreamTrack> tracks = localVideo.srcObject!.getTracks();
    for (var track in tracks) {
      track.stop();
    }

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (peerConnection != null) peerConnection!.close();

    if (roomId != null) {
      var db = FirebaseFirestore.instance;
      var roomRef = db.collection('rooms').doc(roomId);
      var calleeCandidates = await roomRef.collection('calleeCandidates').get();
      for (var doc in calleeCandidates.docs) {
        doc.reference.delete();
      }

      var callerCandidates = await roomRef.collection('callerCandidates').get();
      for (var doc in callerCandidates.docs) {
        doc.reference.delete();
      }

      roomRef.delete();
    }

    localStream!.dispose();
    remoteStream?.dispose();
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('ICE Gathering 상태 변화: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Connection 상태 변화: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      debugPrint('Signaling 상태 변화: $state');
    };

    peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ICE 연결상태 변화: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      debugPrint('Stream 추가: $stream');
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}
