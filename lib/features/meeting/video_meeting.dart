import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoMeeting extends StatefulWidget {
  const VideoMeeting({super.key, required this.meetingId});
  final String meetingId;

  @override
  State<VideoMeeting> createState() => _VideoMeetingState();
}

class _VideoMeetingState extends State<VideoMeeting> {
  String _status = '초기화됨';
  bool _isInitialized = false;
  bool _isDummyMode = false;
  bool _isDisposed = false;
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    debugPrint('VideoMeeting initState 호출됨');
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (_isDisposed) return;
    
    try {
      debugPrint('카메라 초기화 시작');
      _safeSetState(() {
        _status = '카메라 초기화 중...';
      });

      // 렌더러 초기화
      await _localRenderer.initialize();
      debugPrint('렌더러 초기화 완료');

      if (!_isDisposed) {
        _safeSetState(() {
          _isInitialized = true;
          _status = '카메라 초기화 완료';
        });
      }

    } catch (e) {
      debugPrint('카메라 초기화 오류: $e');
      if (!_isDisposed) {
        _safeSetState(() {
          _status = '카메라 초기화 오류: $e';
        });
      }
    }
  }

  // 안전한 setState 호출
  void _safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      try {
        setState(fn);
      } catch (e) {
        debugPrint('setState 오류: $e');
      }
    }
  }

  Future<void> _startCamera() async {
    if (_isDisposed) return;
    
    try {
      debugPrint('카메라 시작 시도');
      _safeSetState(() {
        _status = '카메라 시작 중...';
      });

      // 시뮬레이터 체크 (iOS 시뮬레이터에서는 카메라가 없음)
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        debugPrint('iOS 플랫폼 감지됨');
      }

      final localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'width': {'ideal': 640},
          'height': {'ideal': 480},
          'facingMode': 'user',
        },
      });

      debugPrint('카메라 스트림 획득 성공');
      
      if (!_isDisposed) {
        _safeSetState(() {
          _localStream = localStream;
          _localRenderer.srcObject = localStream;
          _status = '카메라 시작됨';
        });
      }

    } catch (e) {
      debugPrint('카메라 시작 오류: $e');
      
      if (_isDisposed) return;
      
      // 시뮬레이터에서 카메라 접근 실패 시 대체 처리
      if (e.toString().contains('NotFoundError') || 
          e.toString().contains('NotAllowedError') ||
          e.toString().contains('NotReadableError')) {
        
        _safeSetState(() {
          _status = '카메라 접근 불가 (시뮬레이터 또는 권한 문제)\n실제 기기에서 테스트해주세요';
        });
        
        // 더미 비디오 스트림 생성 (테스트용)
        _createDummyVideoStream();
      } else {
        _safeSetState(() {
          _status = '카메라 시작 오류: $e';
        });
      }
    }
  }

  void _createDummyVideoStream() {
    if (_isDisposed) return;
    
    debugPrint('더미 비디오 스트림 생성');
    _safeSetState(() {
      _status = '더미 비디오 스트림 (테스트용)';
    });
  }

  void _startDummyVideo() {
    if (_isDisposed) return;
    
    try {
      debugPrint('더미 비디오 시작');
      _safeSetState(() {
        _isDummyMode = true;
        _status = '더미 비디오 모드 (시뮬레이터용)';
      });
    } catch (e) {
      debugPrint('더미 비디오 시작 오류: $e');
    }
  }

  Widget _getVideoContent() {
    if (_isDisposed) {
      return Container(
        color: Colors.grey.shade300,
        child: Center(
          child: Text('위젯이 해제됨', style: TextStyle(color: Colors.grey.shade600)),
        ),
      );
    }
    
    if (_localStream != null) {
      return RTCVideoView(_localRenderer);
    } else if (_isDummyMode) {
      return Container(
        color: Colors.blue.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam, size: 64, color: Colors.blue.shade600),
              SizedBox(height: 16),
              Text(
                '더미 비디오 모드\n(시뮬레이터에서 테스트용)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '실제 카메라는\n실제 기기에서 테스트하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, size: 64, color: Colors.grey.shade600),
              SizedBox(height: 16),
              Text(
                '카메라를 시작하려면\n아래 버튼을 클릭하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _stopCamera() {
    if (_isDisposed) return;
    
    try {
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) => track.stop());
        _localStream!.dispose();
        _localStream = null;
      }
      
      _safeSetState(() {
        _localRenderer.srcObject = null;
        _status = '카메라 중지됨';
      });
      
      debugPrint('카메라 중지 완료');
    } catch (e) {
      debugPrint('카메라 중지 오류: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('VideoMeeting dispose 호출됨');
    _isDisposed = true;
    
    try {
      _stopCamera();
      _localRenderer.dispose();
    } catch (e) {
      debugPrint('dispose 오류: $e');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('VideoMeeting build 호출됨');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('비디오 미팅 - ${widget.meetingId}'),
      ),
      body: Column(
        children: [
          // 상태 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: _isInitialized ? Colors.green.shade100 : Colors.orange.shade100,
            child: Row(
              children: [
                Icon(
                  _isInitialized ? Icons.check_circle : Icons.hourglass_empty,
                  color: _isInitialized ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _status,
                    style: TextStyle(
                      color: _isInitialized ? Colors.green.shade800 : Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // 비디오 뷰
          if (_isInitialized)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: _getVideoContent(),
                  ),
                ),
              ),
            ),
          
          // 컨트롤 버튼들
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _localStream == null ? _startCamera : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('카메라 시작'),
                    ),
                    
                    ElevatedButton(
                      onPressed: _localStream != null ? _stopCamera : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('카메라 중지'),
                    ),
                    
                    ElevatedButton(
                      onPressed: () {
                        _safeSetState(() {
                          _status = '테스트: ${DateTime.now()}';
                        });
                      },
                      child: Text('상태 테스트'),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // 시뮬레이터용 더미 비디오 버튼
                ElevatedButton(
                  onPressed: _localStream == null ? _startDummyVideo : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('더미 비디오 시작 (시뮬레이터용)'),
                ),
              ],
            ),
          ),
          
          // 하단 정보
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade100,
            child: Text(
              '미팅 ID: ${widget.meetingId}\n현재 시간: ${DateTime.now()}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}