import 'package:flutter_webrtc/flutter_webrtc.dart';

enum PeerConnectionStatus {
  initializing,
  connecting,
  connected,
  disconnected,
  failed,
  unknown,
}

enum ICEConnectionStatus { checking, connected, disconnected, failed, unknown }

PeerConnectionStatus peerConnectionStatus(RTCPeerConnectionState state) {
  switch (state) {
    case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
      return PeerConnectionStatus.connecting;
    case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
      return PeerConnectionStatus.connected;
    case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
        RTCPeerConnectionState.RTCPeerConnectionStateClosed:
      return PeerConnectionStatus.disconnected;
    case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
      return PeerConnectionStatus.failed;
    default:
      return PeerConnectionStatus.unknown;
  }
}

ICEConnectionStatus iceConnectionStatus(RTCIceConnectionState state) {
  switch (state) {
    case RTCIceConnectionState.RTCIceConnectionStateChecking:
      return ICEConnectionStatus.checking;
    case RTCIceConnectionState.RTCIceConnectionStateConnected ||
        RTCIceConnectionState.RTCIceConnectionStateCompleted:
      return ICEConnectionStatus.connected;
    case RTCIceConnectionState.RTCIceConnectionStateFailed:
      return ICEConnectionStatus.failed;
    case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
      return ICEConnectionStatus.disconnected;
    default:
      return ICEConnectionStatus.unknown;
  }
}

String iceConnectionStatusMessage(ICEConnectionStatus status) {
  switch (status) {
    case ICEConnectionStatus.checking:
      return '연결 대기';
    case ICEConnectionStatus.connected:
      return '연결됨';
    case ICEConnectionStatus.failed:
      return '연결 실패';
    case ICEConnectionStatus.disconnected:
      return '연결 끊김';
    case ICEConnectionStatus.unknown:
      return '상태 확인 중...';
  }
}

String peerConnectionStatusMessage(PeerConnectionStatus status) {
  switch (status) {
    case PeerConnectionStatus.initializing:
      return '연결 초기화 중...';
    case PeerConnectionStatus.connecting:
      return '연결 중...';
    case PeerConnectionStatus.connected:
      return '연결됨';
    case PeerConnectionStatus.disconnected:
      return '연결 끊김';
    case PeerConnectionStatus.failed:
      return '연결 실패';
    case PeerConnectionStatus.unknown:
      return '상태 확인 중...';
  }
}
