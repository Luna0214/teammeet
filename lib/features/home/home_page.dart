import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_service.dart';
import '../chat/user_list.dart';
import '../chat/chatroom_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  
  Widget _bodyWidget() {
    return IndexedStack(
      index: currentPageIndex,
      children: [
        UserList(),
        ChatroomList(),
      ],
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
          icon: Icon(Icons.home, color: Colors.blue,),
          label: '유저 목록',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Colors.blue,),
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
        title: Text(currentPageIndex == 0 ? '유저 목록' : '채팅방', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () => LoginService.logout(context),
            icon: const Icon(Icons.logout, color: Colors.white,),
          ),
        ],
      ),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavBar(),
      
    );
  }
}