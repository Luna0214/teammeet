# TeamMeet(Still in construction)

A cross-platform real-time communication app built with Flutter and WebRTC.

## 🚀 Features(예정)

- 🔒 Firebase Auth 기반 로그인
- 📞 WebRTC 기반 화상/음성 통화
- 💬 실시간 채팅 (Firebase/Socket)
- 👥 그룹방 생성 및 초대
- 📱 멀티 플랫폼 지원 (iOS, Android, Web, Windows, macOS)

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