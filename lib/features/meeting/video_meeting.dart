import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:teammeet/features/meeting/signaling.dart';
import 'package:teammeet/features/meeting/video_meeting_service.dart';

class VideoMeeting extends StatefulWidget {
  const VideoMeeting({super.key, required this.calleeUid});
  final String calleeUid;

  @override
  State<VideoMeeting> createState() => _VideoMeetingState();
}

class _VideoMeetingState extends State<VideoMeeting> {
  Signaling signaling = Signaling();
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController roomIdController = TextEditingController(text: '');

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

    signaling.onAddRemoteStream = (MediaStream stream) {
      setState(() {
        remoteRenderer.srcObject = stream;
      });
    };

    await signaling.openUserMedia(localRenderer, remoteRenderer);

    roomId = await signaling.createRoom(remoteRenderer);

    setState(() {
      roomId = roomId;
    });

    await VideoMeetingService.startVideoCall(roomId!, widget.calleeUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('비디오 미팅'),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Room ID:${roomId ?? 'Loading...'}"),
            Text("caller Receiver: ${widget.calleeUid}"),
            SizedBox(
              width: 300,
              height: 300,
              child: RTCVideoView(localRenderer),
            ),
            SizedBox(
              width: 300,
              height: 300,
              child: RTCVideoView(remoteRenderer),
            ),
            ElevatedButton(
              onPressed: () {
                signaling.hangUp(localRenderer);
              },
              child: Text('Hang Up'),
            ),
          ],
        ),
      ),
    );
  }
}
