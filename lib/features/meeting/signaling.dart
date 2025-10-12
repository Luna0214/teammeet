import 'dart:async';

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
  Function(bool isConnected)? onConnectionStatusChanged;

  StreamSubscription? _remoteSessionDescriptionSubscription;
  StreamSubscription? _calleeCandidatesSubscription;
  StreamSubscription? _callerCandidatesSubscription;

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
    MediaStream stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'width': {'ideal': 1200},
        'height': {'ideal': 1600},
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
        // debugPrint('Candidate 획득: ${candidate.toMap()}');
        callerCandidatesCollection.add(candidate.toMap());
      };

      // NOTE: 방 생성
      RTCSessionDescription offer = await peerConnection!.createOffer();
      await peerConnection!.setLocalDescription(offer);

      Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};
      await roomRef.set(roomWithOffer);
      roomId = roomRef.id;

      peerConnection?.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          //debugPrint('Remote Stream 획득: ${event.streams[0]}');
          onAddRemoteStream?.call(event.streams[0]);
          remoteStream = event.streams[0];
        }
      };

      // NOTE: Remote Session Description 리스너 설정
      _remoteSessionDescriptionSubscription = roomRef.snapshots().listen((
        snapshot,
      ) async {
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
      _calleeCandidatesSubscription = roomRef
          .collection('calleeCandidates')
          .snapshots()
          .listen((snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                Map<String, dynamic> data =
                    change.doc.data() as Map<String, dynamic>;
                //debugPrint('새로운 Remote Candidate 획득: ${jsonEncode(data)}');

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

      return roomId!;
    } catch (e) {
      debugPrint('createRoom 오류: $e');
      return "";
    }
  }

  Future<void> joinRoom(String roomId) async {
    this.roomId = roomId;
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
      _callerCandidatesSubscription = roomRef
          .collection('callerCandidates')
          .snapshots()
          .listen((snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                Map<String, dynamic> data =
                    change.doc.data() as Map<String, dynamic>;
                //debugPrint('새로운 Remote Candidate 획득: ${jsonEncode(data)}');
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
    try {
      _remoteSessionDescriptionSubscription?.cancel();
      _remoteSessionDescriptionSubscription = null;
      _calleeCandidatesSubscription?.cancel();
      _calleeCandidatesSubscription = null;
      _callerCandidatesSubscription?.cancel();
      _callerCandidatesSubscription = null;

      // 로컬 비디오 트랙 정리
      if (localVideo.srcObject != null) {
        List<MediaStreamTrack> tracks = localVideo.srcObject!.getTracks();
        for (var track in tracks) {
          track.stop();
        }
        debugPrint('로컬 비디오 트랙 정리 완료');
      }

      // 원격 스트림 정리
      if (remoteStream != null) {
        remoteStream!.getTracks().forEach((track) => track.stop());
        debugPrint('원격 스트림 정리 완료');
      }

      // PeerConnection 정리
      if (peerConnection != null) {
        await peerConnection!.close();
        peerConnection = null;
        debugPrint('PeerConnection 정리 완료');
      }

      // Firestore 방(Room&Call) 데이터 정리
      if (roomId != null) {
        try {
          debugPrint('방 삭제 시작 - roomId: $roomId');
          var db = FirebaseFirestore.instance;
          var roomRef = db.collection('rooms').doc(roomId);
          var callRef = db.collection('calls').doc(roomId);

          WriteBatch batch = db.batch();

          var calleeCandidates =
              await roomRef.collection('calleeCandidates').get();
          for (var doc in calleeCandidates.docs) {
            batch.delete(doc.reference);
          }

          var callerCandidates =
              await roomRef.collection('callerCandidates').get();
          for (var doc in callerCandidates.docs) {
            batch.delete(doc.reference);
          }
          batch.delete(roomRef);
          batch.delete(callRef);

          await batch.commit();
          debugPrint('Firestore 방 데이터 및 서브컬렉션 정리 완료');
        } catch (e) {
          debugPrint('Firestore 정리 중 오류: $e');
          debugPrint('오류 타입: ${e.runtimeType}');

          if (e.toString().contains('not-found') ||
              e.toString().contains('permission-denied')) {
            debugPrint('문서가 이미 삭제되었거나 권한이 없음 - 정상적인 상황');
          }
        }
      } else {
        debugPrint('roomId가 null이므로 방 삭제를 건너뜀');
      }

      // 스트림 리소스 정리
      if (localStream != null) {
        localStream!.dispose();
        localStream = null;
        debugPrint('로컬 스트림 정리 완료');
      }

      if (remoteStream != null) {
        remoteStream!.dispose();
        remoteStream = null;
        debugPrint('원격 스트림 정리 완료');
      }

      debugPrint('통화 종료 완료');
    } catch (e) {
      debugPrint('통화 종료 중 오류 발생: $e');
    }
  }

  Future<void> toggleVideo() async {
    if (localStream != null) {
      List<MediaStreamTrack> videoTracks = localStream!.getVideoTracks();
      for (var track in videoTracks) {
        track.enabled = !track.enabled;
        debugPrint('비디오 트랙 상태 변경: ${track.enabled}');
      }
    }
  }

  Future<void> toggleAudio() async {
    if (localStream != null) {
      List<MediaStreamTrack> audioTracks = localStream!.getAudioTracks();
      for (var track in audioTracks) {
        track.enabled = !track.enabled;
        debugPrint('오디오 트랙 상태 변경: ${track.enabled}');
      }
    }
  }

  bool isVideoEnabled() {
    if (localStream != null) {
      List<MediaStreamTrack> videoTracks = localStream!.getVideoTracks();
      return videoTracks.isNotEmpty && videoTracks.first.enabled;
    }
    return false;
  }

  bool isAudioEnabled() {
    if (localStream != null) {
      List<MediaStreamTrack> audioTracks = localStream!.getAudioTracks();
      return audioTracks.isNotEmpty && audioTracks.first.enabled;
    }
    return false;
  }

  // NOTE: 상태 변화 모니터링
  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('ICE Gathering 상태 변화: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Connection 상태 변화: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        onConnectionStatusChanged?.call(true);
      } else if (state ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        onConnectionStatusChanged?.call(false);
      }
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      debugPrint('Signaling 상태 변화: $state');
    };

    peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ICE 연결상태 변화: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        onConnectionStatusChanged?.call(true);
      } else if (state ==
              RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        onConnectionStatusChanged?.call(false);
      }
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      debugPrint('Stream 추가: $stream');
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
      onConnectionStatusChanged?.call(true);
    };
  }
}
