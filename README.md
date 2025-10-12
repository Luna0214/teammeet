# TeamMeet

WebRTC 및 Firebase를 기반 실시간 화상통화 및 채팅 MVP 어플리케이션.

## How to demo?

- Firebase 인증 파일(IOS, Android, Web) 세팅 후 실행
- 기존 파일 보안 목적상 gitignore에 포함

## 🚀 Features(예정)

- 🔒 Firebase Auth 기반 로그인(완료)
- 📞 WebRTC 기반 화상 통화(완료)
- 💬 실시간 채팅 (Firebase/Socket): 구현 중
- 📱 멀티 플랫폼 지원 (iOS, Android, Web)

## 🛠 Tech Stack

- Flutter 3.29.2
- flutter_bloc + hydrated_bloc
- flutter_webrtc
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