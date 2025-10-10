import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
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
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeMeeting();
  }

  @override
  void dispose() {
    signaling.onConnectionStatusChanged = null;
    signaling.onAddRemoteStream = null;
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  void _initializeMeeting() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    signaling.onConnectionStatusChanged = (bool connected) {
      if (!mounted) return;
      setState(() {
        isConnected = connected;
      });
    };

    signaling.onAddRemoteStream = (MediaStream stream) {
      if (!mounted) return;
      setState(() {
        remoteRenderer.srcObject = stream;
      });
    };

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

  Widget _mobileBody() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // 메인 비디오 (원격 렌더러)
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  isConnected
                      ? RTCVideoView(remoteRenderer)
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
                              isConnected ? '연결됨' : '연결 대기',
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
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: RTCVideoView(localRenderer),
              ),
            ),
          ),
        ],
      ),
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
                  height: 300,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: RTCVideoView(localRenderer),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // 원격 비디오 (상대방 화면)
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          isConnected
                              ? RTCVideoView(remoteRenderer)
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
                                      isConnected ? '연결됨' : '연결 대기',
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
          // 비디오 켜기/끄기
          ToggleButton(
            iconOn: Icons.videocam,
            iconOff: Icons.videocam_off,
            onFunction: () {},
            offFunction: () {},
          ),
          // 오디오 켜기/끄기
          ToggleButton(
            iconOn: Icons.mic,
            iconOff: Icons.mic_off,
            onFunction: () {},
            offFunction: () {},
          ),
          IconButton(
            onPressed: () async {
              try {
                debugPrint('통화 종료 버튼 클릭');

                // WebRTC 연결 정리
                await signaling.hangUp(localRenderer);
                debugPrint('WebRTC 연결 정리 완료');

                // 비디오 미팅 서비스 종료
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
            },
            icon: Icon(Icons.call_end),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('비디오 미팅'),
      ),
      body: kIsWeb ? _webBody() : _mobileBody(),
      bottomNavigationBar: kIsWeb ? null : _callControlButton(),
    );
  }
}
