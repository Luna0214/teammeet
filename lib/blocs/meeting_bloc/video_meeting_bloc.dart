import 'package:flutter_bloc/flutter_bloc.dart';
import 'video_meeting_event.dart';

// BLoC
class VideoMeetingBloc extends Bloc<VideoMeetingEvent, VideoMeetingState> {
  VideoMeetingBloc() : super(VideoMeetingStatus()) {
    on<PeerConnectionStatusChanged>(_onPeerConnectionStatusChanged);
    on<ICEConnectionStatusChanged>(_onICEConnectionStatusChanged);
    on<LocalVideoStatusChanged>(_onLocalVideoStatusChanged);
    on<LocalAudioStatusChanged>(_onLocalAudioStatusChanged);
    on<RemoteVideoStatusChanged>(_onRemoteVideoStatusChanged);
    on<RemoteAudioStatusChanged>(_onRemoteAudioStatusChanged);
  }

  void _onPeerConnectionStatusChanged(
    PeerConnectionStatusChanged event,
    Emitter<VideoMeetingState> emit,
  ) {
    if (state is VideoMeetingStatus) {
      final currentState = state as VideoMeetingStatus;
      emit(currentState.copyWith(peerConnectionStatus: event.status));
    } else {
      emit(VideoMeetingStatus(peerConnectionStatus: event.status));
    }
  }

  void _onICEConnectionStatusChanged(
    ICEConnectionStatusChanged event,
    Emitter<VideoMeetingState> emit,
  ) {
    if (state is VideoMeetingStatus) {
      final currentState = state as VideoMeetingStatus;
      emit(currentState.copyWith(iceConnectionStatus: event.status));
    } else {
      emit(VideoMeetingStatus(iceConnectionStatus: event.status));
    }
  }

  void _onLocalVideoStatusChanged(
    LocalVideoStatusChanged event,
    Emitter<VideoMeetingState> emit,
  ) {
    if (state is VideoMeetingStatus) {
      final currentState = state as VideoMeetingStatus;
      emit(currentState.copyWith(localVideoEnabled: event.isEnabled));
    } else {
      emit(VideoMeetingStatus(localVideoEnabled: event.isEnabled));
    }
  }

  void _onLocalAudioStatusChanged(
    LocalAudioStatusChanged event,
    Emitter<VideoMeetingState> emit,
  ) {
    if (state is VideoMeetingStatus) {
      final currentState = state as VideoMeetingStatus;
      emit(currentState.copyWith(localAudioEnabled: event.isEnabled));
    } else {
      emit(VideoMeetingStatus(localAudioEnabled: event.isEnabled));
    }
  }

  void _onRemoteVideoStatusChanged(
    RemoteVideoStatusChanged event,
    Emitter<VideoMeetingState> emit,
  ) {
    if (state is VideoMeetingStatus) {
      final currentState = state as VideoMeetingStatus;
      emit(currentState.copyWith(remoteVideoEnabled: event.isEnabled));
    } else {
      emit(VideoMeetingStatus(remoteVideoEnabled: event.isEnabled));
    }
  }

  void _onRemoteAudioStatusChanged(
    RemoteAudioStatusChanged event,
    Emitter<VideoMeetingState> emit,
  ) {
    if (state is VideoMeetingStatus) {
      final currentState = state as VideoMeetingStatus;
      emit(currentState.copyWith(remoteAudioEnabled: event.isEnabled));
    } else {
      emit(VideoMeetingStatus(remoteAudioEnabled: event.isEnabled));
    }
  }
}
