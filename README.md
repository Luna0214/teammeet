# TeamMeet
<img width="40%" src="https://github.com/user-attachments/assets/52504df2-d5ea-420a-956c-3318cf42c6ca"/>

WebRTC 및 Firebase를 기반 실시간 화상통화 및 채팅 MVP 어플리케이션.

## How to demo?
<img width="80%" src="https://github.com/user-attachments/assets/e3cd6888-23a8-4e00-a9f4-5e312ec95aa2"/>

- Firebase 인증 파일(IOS, Android, Web) 세팅 후 실행
- 인증 파일 위치: 
    IOS: root/Runner/GoogleSevice-info.plist
    Android: root/android/app/google-services.json
    Web: Firebase 설정 이후, lib/firebase_options.dart에 설정 정보 추가
- 기존 파일 보안 목적상 gitignore에 포함

## 🚀 Features(예정)
<img width="80%" src="https://github.com/user-attachments/assets/fa71cfe1-9501-442b-be1b-f49c29ed11a0"/>

- 🔒 Firebase Auth 기반 로그인(완료)
- 📹 WebRTC 기반 화상 통화(완료)
- 📞 WebRTC 기반 음성 통화 - 예정
- 💬 실시간 채팅 (WebRTC DataChannel) - 예정
- 📱 멀티 플랫폼 지원 (iOS, Android, Web)


## 🛠 Tech Stack

- Flutter 3.29.2
- flutter_bloc 9.1.1
- flutter_webrtc 1.0.0
- Firebase Auth / Firestore / Firebase Storage
- WebSocket
- MethodChannel (Kotlin, Swift)
- Git + GitHub

## 📁 Folder Structure

```bash
lib/
├── main.dart
├── core/
│   ├── platform/ 
│   ├── method_channel/
│   └── utils/
├── features/
│   ├── auth/
│   ├── chat/
│   ├── meeting/
│   └── home/
├── shared/
│   └── widgets/
├── blocs/
│   ├── auth_bloc/
│   ├── chat_bloc/
│   └── meeting_bloc/
/
