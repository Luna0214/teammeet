import 'package:teammeet/blocs/meeting_bloc/video_meeting_status.dart';

abstract class VideoMeetingEvent {}

// 연결
// NOTE: 전체 연결
class PeerConnectionStatusChanged extends VideoMeetingEvent {
  final PeerConnectionStatus status;
  PeerConnectionStatusChanged(this.status);
}

// NOTE: 실제 원격 연결
class ICEConnectionStatusChanged extends VideoMeetingEvent {
  final ICEConnectionStatus status;
  ICEConnectionStatusChanged(this.status);
}

// 로컬
class LocalVideoStatusChanged extends VideoMeetingEvent {
  final bool isEnabled;
  LocalVideoStatusChanged(this.isEnabled);
}

class LocalAudioStatusChanged extends VideoMeetingEvent {
  final bool isEnabled;
  LocalAudioStatusChanged(this.isEnabled);
}

// 원격
class RemoteVideoStatusChanged extends VideoMeetingEvent {
  final bool isEnabled;
  RemoteVideoStatusChanged(this.isEnabled);
}

class RemoteAudioStatusChanged extends VideoMeetingEvent {
  final bool isEnabled;
  RemoteAudioStatusChanged(this.isEnabled);
}

// 통합
class VideoMeetingStatusUpdated extends VideoMeetingEvent {
  final PeerConnectionStatus peerConnectionStatus;
  final ICEConnectionStatus iceConnectionStatus;
  final bool localVideoEnabled;
  final bool localAudioEnabled;
  final bool remoteVideoEnabled;
  final bool remoteAudioEnabled;

  VideoMeetingStatusUpdated({
    required this.peerConnectionStatus,
    required this.iceConnectionStatus,
    required this.localVideoEnabled,
    required this.localAudioEnabled,
    required this.remoteVideoEnabled,
    required this.remoteAudioEnabled,
  });
}

// 상태
abstract class VideoMeetingState {}

// NOTE: provider 추가 시, 개인 ON/OFF 설정 초기값에 적용
class VideoMeetingStatus extends VideoMeetingState {
  final PeerConnectionStatus peerConnectionStatus;
  final ICEConnectionStatus iceConnectionStatus;
  final bool localVideoEnabled;
  final bool localAudioEnabled;
  final bool remoteVideoEnabled;
  final bool remoteAudioEnabled;

  VideoMeetingStatus({
    this.peerConnectionStatus = PeerConnectionStatus.initializing,
    this.iceConnectionStatus = ICEConnectionStatus.checking,
    this.localVideoEnabled = false,
    this.localAudioEnabled = false,
    this.remoteVideoEnabled = false,
    this.remoteAudioEnabled = false,
  });

  VideoMeetingStatus copyWith({
    PeerConnectionStatus? peerConnectionStatus,
    ICEConnectionStatus? iceConnectionStatus,
    bool? localVideoEnabled,
    bool? localAudioEnabled,
    bool? remoteVideoEnabled,
    bool? remoteAudioEnabled,
  }) {
    return VideoMeetingStatus(
      peerConnectionStatus: peerConnectionStatus ?? this.peerConnectionStatus,
      iceConnectionStatus: iceConnectionStatus ?? this.iceConnectionStatus,
      localVideoEnabled: localVideoEnabled ?? this.localVideoEnabled,
      localAudioEnabled: localAudioEnabled ?? this.localAudioEnabled,
      remoteVideoEnabled: remoteVideoEnabled ?? this.remoteVideoEnabled,
      remoteAudioEnabled: remoteAudioEnabled ?? this.remoteAudioEnabled,
    );
  }
}
