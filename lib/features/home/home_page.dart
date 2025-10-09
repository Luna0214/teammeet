import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teammeet/core/model/call_model.dart';
import 'package:teammeet/features/meeting/ringing_page.dart';
import 'package:teammeet/shared/app_router.dart';
import '../auth/login_service.dart';
import '../auth/login_page.dart';
import '../chat/user_list.dart';
import '../chat/chatroom_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  StreamSubscription? _incomingcallSubscription;

  @override
  void initState() {
    super.initState();
    _incomingcallSubscription = _initializeIncomingCallSubscription();
  }

  @override
  void dispose() {
    _incomingcallSubscription?.cancel();
    _incomingcallSubscription = null;
    super.dispose();
  }

  StreamSubscription? _initializeIncomingCallSubscription() {
    return FirebaseFirestore.instance
        .collection('calls')
        .where('calleeUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isEmpty) return;

            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                CallModel data = CallModel.fromJson(change.doc.data()!);
                debugPrint('새로운 통화 추가: ${data.toJson()}');

                // 새로운 통화가 추가되었을 때 RingingPage 페이지로 이동
                AppRouter.push(
                  RingingPage(roomId: data.roomId, callerUid: data.callerUid),
                );
              }
            }
          },
          onError: (error) {
            debugPrint('통화 리스너 에러: $error');
          },
        );
  }

  Widget _bodyWidget() {
    return IndexedStack(
      index: currentPageIndex,
      children: [UserList(), ChatroomList()],
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentPageIndex,
      onTap: (index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.blue),
          label: '유저 목록',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Colors.blue),
          label: '채팅방 목록',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Column(
        children: [
          const CircularProgressIndicator(),
          const Text('지속될 경우, 로그아웃 이후 다시 로그인 해주세요.'),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentPageIndex == 0 ? '유저 목록' : '채팅방',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await _incomingcallSubscription?.cancel();
                await LoginService.logout();
              } catch (e) {
                debugPrint('로그아웃 중 오류: $e');
              }
              if (mounted) {
                AppRouter.pushAndRemoveUntil(LoginPage());
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavBar(),
    );
  }
}
