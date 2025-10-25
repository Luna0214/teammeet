import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:teammeet/blocs/meeting_bloc/video_meeting_bloc.dart';
import 'package:teammeet/blocs/meeting_bloc/video_meeting_event.dart';
import 'package:teammeet/blocs/meeting_bloc/video_meeting_status.dart';
import 'package:teammeet/features/home/home_page.dart';
import 'package:teammeet/features/meeting/signaling.dart';
import 'package:teammeet/features/meeting/video_meeting_service.dart';
import 'package:teammeet/shared/app_router.dart';
import 'package:teammeet/shared/widgets/toggle_button.dart';

class VideoMeeting extends StatefulWidget {
  const VideoMeeting({
    super.key,
    required this.calleeUid,
    required this.isCaller,
    this.roomId,
  });
  final String calleeUid;
  final bool isCaller;
  final String? roomId;

  @override
  State<VideoMeeting> createState() => _VideoMeetingState();
}

class _VideoMeetingState extends State<VideoMeeting> {
  Signaling signaling = Signaling();
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController roomIdController = TextEditingController(text: '');
  bool isVideoEnabled = true;
  bool isAudioEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeMeeting();
  }

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  void _initializeMeeting() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    // Signaling에 Bloc 전달
    signaling.setBloc(context.read<VideoMeetingBloc>());

    await signaling.openUserMedia(localRenderer, remoteRenderer);

    if (widget.isCaller) {
      final createdRoomId = await signaling.createRoom(remoteRenderer);
      setState(() {
        roomId = createdRoomId;
      });
      await VideoMeetingService.startVideoCall(createdRoomId, widget.calleeUid);
    } else {
      final existingRoomId = widget.roomId;
      if (existingRoomId != null && existingRoomId.isNotEmpty) {
        setState(() {
          roomId = existingRoomId;
        });
        await signaling.joinRoom(existingRoomId);
      }
    }
  }

  void _toggleVideo() {
    signaling.toggleVideo();
  }

  void _toggleAudio() {
    signaling.toggleAudio();
  }

  Future<void> _hangUp() async {
    try {
      debugPrint('통화 종료 버튼 클릭');

      await signaling.hangUp(localRenderer);
      debugPrint('WebRTC 연결 정리 완료');

      await VideoMeetingService.endVideoCall(roomId ?? '');
      debugPrint('비디오 미팅 서비스 종료 완료');

      // HomePage로 이동
      if (mounted) {
        AppRouter.pushAndRemoveUntil(HomePage());
      }
    } catch (e) {
      debugPrint('통화 종료 중 오류 발생: $e');

      // 오류가 발생해도 HomePage로 이동
      if (mounted) {
        AppRouter.pushAndRemoveUntil(HomePage());
      }
    }
  }

  Widget _mobileBody() {
    return BlocBuilder<VideoMeetingBloc, VideoMeetingState>(
      builder: (context, state) {
        return Stack(
          children: [
            // 메인 비디오 (원격 렌더러)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child:
                    state is VideoMeetingStatus &&
                            state.iceConnectionStatus ==
                                ICEConnectionStatus.connected
                        ? RTCVideoView(
                          remoteRenderer,
                          filterQuality: FilterQuality.medium,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                        : Container(
                          color: Colors.black,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam_off,
                                size: 48,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Text(
                                iceConnectionStatusMessage(
                                  state is VideoMeetingStatus
                                      ? state.iceConnectionStatus
                                      : ICEConnectionStatus.unknown,
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
            // 로컬 비디오 작은 박스
            Positioned(
              bottom: 32,
              right: 16,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child:
                      state is VideoMeetingStatus &&
                              state.peerConnectionStatus ==
                                  PeerConnectionStatus.connected
                          ? RTCVideoView(
                            localRenderer,
                            objectFit:
                                RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                          )
                          : Container(
                            color: Colors.black,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam_off,
                                  size: 48,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  peerConnectionStatusMessage(
                                    state is VideoMeetingStatus
                                        ? state.peerConnectionStatus
                                        : PeerConnectionStatus.unknown,
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _webBody() {
    return Center(
      child: Column(
        children: [
          Text("Room ID:${roomId ?? 'Loading...'}"),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로컬 비디오 (내 화면)
                SizedBox(
                  width: 300,
                  height: 400,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BlocBuilder<VideoMeetingBloc, VideoMeetingState>(
                        builder: (context, state) {
                          return state is VideoMeetingStatus &&
                                  state.peerConnectionStatus ==
                                      PeerConnectionStatus.connected &&
                                  state.localVideoEnabled
                              ? RTCVideoView(
                                localRenderer,
                                filterQuality: FilterQuality.high,
                                objectFit:
                                    RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                              )
                              : Container(
                                color: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.videocam_off,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '카메라가 비활성화되었습니다',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // 원격 비디오 (상대방 화면)
                SizedBox(
                  width: 300,
                  height: 400,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BlocBuilder<VideoMeetingBloc, VideoMeetingState>(
                        builder: (context, state) {
                          if (state is VideoMeetingStatus &&
                              state.iceConnectionStatus !=
                                  ICEConnectionStatus.connected) {
                            return Container(
                              color: Colors.black,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videocam_off,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    iceConnectionStatusMessage(
                                      state.iceConnectionStatus,
                                    ),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return state is VideoMeetingStatus &&
                                  state.iceConnectionStatus ==
                                      ICEConnectionStatus.connected &&
                                  state.remoteVideoEnabled
                              ? RTCVideoView(
                                remoteRenderer,
                                filterQuality: FilterQuality.high,
                                objectFit:
                                    RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                              )
                              : Container(
                                color: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.videocam_off,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '상대방이 카메라를 비활성화했습니다',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _callControlButton(),
          ),
        ],
      ),
    );
  }

  Widget _callControlButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BlocBuilder<VideoMeetingBloc, VideoMeetingState>(
            builder: (context, state) {
              bool isVideoEnabled = true;
              if (state is VideoMeetingStatus) {
                isVideoEnabled = state.localVideoEnabled;
              }

              return ToggleButton(
                iconOn: Icons.videocam,
                iconOff: Icons.videocam_off,
                initialState: isVideoEnabled,
                onFunction: () => _toggleVideo(),
                offFunction: () => _toggleVideo(),
              );
            },
          ),
          BlocBuilder<VideoMeetingBloc, VideoMeetingState>(
            builder: (context, state) {
              bool isAudioEnabled = true;
              if (state is VideoMeetingStatus) {
                isAudioEnabled = state.localAudioEnabled;
              }

              return ToggleButton(
                iconOn: Icons.mic,
                iconOff: Icons.mic_off,
                initialState: isAudioEnabled,
                onFunction: () => _toggleAudio(),
                offFunction: () => _toggleAudio(),
              );
            },
          ),
          IconButton(
            onPressed: () async {
              if (mounted) {
                await _hangUp();
              }
            },
            icon: Icon(Icons.call_end),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoMeetingBloc, VideoMeetingState>(
      listener: (context, state) {
        if (state is VideoMeetingStatus) {
          debugPrint('미팅 상태 업데이트: ${state.toString()}');
          if (state.remoteVideoEnabled || state.remoteAudioEnabled) {
            if (signaling.remoteStream != null) {
              setState(() {
                remoteRenderer.srcObject = signaling.remoteStream;
              });
            } else {
              setState(() {
                remoteRenderer.srcObject = null;
              });
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('비디오 미팅'),
        ),
        body: kIsWeb ? _webBody() : _mobileBody(),
        bottomNavigationBar: kIsWeb ? null : _callControlButton(),
      ),
    );
  }
}
