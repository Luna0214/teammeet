import 'package:flutter_bloc/flutter_bloc.dart';

// 이벤트
abstract class VideoMeetingEvent {}

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

class RemoteVideoConnectionStatusChanged extends VideoMeetingEvent {
  final bool isConnected;
  RemoteVideoConnectionStatusChanged(this.isConnected);
}

class RemoteStreamReceived extends VideoMeetingEvent {
  final bool hasVideo;
  final bool hasAudio;
  RemoteStreamReceived({required this.hasVideo, required this.hasAudio});
}

// 통합
class VideoMeetingStatusUpdated extends VideoMeetingEvent {
  final bool isConnected;
  final bool localVideoEnabled;
  final bool localAudioEnabled;
  final bool remoteVideoEnabled;
  final bool remoteAudioEnabled;

  VideoMeetingStatusUpdated({
    required this.isConnected,
    required this.localVideoEnabled,
    required this.localAudioEnabled,
    required this.remoteVideoEnabled,
    required this.remoteAudioEnabled,
  });
}

// 상태
abstract class VideoMeetingState {}

class VideoMeetingInitial extends VideoMeetingState {}

class VideoMeetingStatus extends VideoMeetingState {
  final bool isConnected;
  final bool localVideoEnabled;
  final bool localAudioEnabled;
  final bool remoteVideoEnabled;
  final bool remoteAudioEnabled;
  final bool hasRemoteStream;

  VideoMeetingStatus({
    this.isConnected = false,
    this.localVideoEnabled = true,
    this.localAudioEnabled = true,
    this.remoteVideoEnabled = false,
    this.remoteAudioEnabled = false,
    this.hasRemoteStream = false,
  });

  VideoMeetingStatus copyWith({
    bool? isConnected,
    bool? localVideoEnabled,
    bool? localAudioEnabled,
    bool? remoteVideoEnabled,
    bool? remoteAudioEnabled,
    bool? hasRemoteStream,
  }) {
    return VideoMeetingStatus(
      isConnected: isConnected ?? this.isConnected,
      localVideoEnabled: localVideoEnabled ?? this.localVideoEnabled,
      localAudioEnabled: localAudioEnabled ?? this.localAudioEnabled,
      remoteVideoEnabled: remoteVideoEnabled ?? this.remoteVideoEnabled,
      remoteAudioEnabled: remoteAudioEnabled ?? this.remoteAudioEnabled,
      hasRemoteStream: hasRemoteStream ?? this.hasRemoteStream,
    );
  }
}

// BLoC
class VideoMeetingBloc extends Bloc<VideoMeetingEvent, VideoMeetingState> {
  VideoMeetingBloc() : super(VideoMeetingInitial()) {
    on<LocalVideoStatusChanged>(_onLocalVideoStatusChanged);
    on<LocalAudioStatusChanged>(_onLocalAudioStatusChanged);
    on<RemoteVideoStatusChanged>(_onRemoteVideoStatusChanged);
    on<RemoteVideoConnectionStatusChanged>(
      _onRemoteVideoConnectionStatusChanged,
    );
    on<RemoteStreamReceived>(_onRemoteStreamReceived);
    on<VideoMeetingStatusUpdated>(_onVideoMeetingStatusUpdated);
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

  void _onRemoteVideoConnectionStatusChanged(
    RemoteVideoConnectionStatusChanged event,
    Emitter<VideoMeetingState> emit,
  ) {
    if (state is VideoMeetingStatus) {
      final currentState = state as VideoMeetingStatus;
      emit(currentState.copyWith(isConnected: event.isConnected));
    } else {
      emit(VideoMeetingStatus(isConnected: event.isConnected));
    }
  }

  void _onRemoteStreamReceived(
    RemoteStreamReceived event,
    Emitter<VideoMeetingState> emit,
  ) {
    if (state is VideoMeetingStatus) {
      final currentState = state as VideoMeetingStatus;
      emit(
        currentState.copyWith(
          hasRemoteStream: true,
          remoteVideoEnabled: event.hasVideo,
          remoteAudioEnabled: event.hasAudio,
        ),
      );
    } else {
      emit(
        VideoMeetingStatus(
          hasRemoteStream: true,
          remoteVideoEnabled: event.hasVideo,
          remoteAudioEnabled: event.hasAudio,
        ),
      );
    }
  }

  void _onVideoMeetingStatusUpdated(
    VideoMeetingStatusUpdated event,
    Emitter<VideoMeetingState> emit,
  ) {
    emit(
      VideoMeetingStatus(
        isConnected: event.isConnected,
        localVideoEnabled: event.localVideoEnabled,
        localAudioEnabled: event.localAudioEnabled,
        remoteVideoEnabled: event.remoteVideoEnabled,
        remoteAudioEnabled: event.remoteAudioEnabled,
        hasRemoteStream: true,
      ),
    );
  }
}
