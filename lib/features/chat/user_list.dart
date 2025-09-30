import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teammeet/features/meeting/video_meeting.dart';
import 'package:teammeet/shared/app_router.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> userInfoStream;

  @override
  void initState() {
    super.initState();
    // Fireabase 유저 목록 가져오기
    userInfoStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userInfoStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
        List<Map<String, dynamic>> users =
            snapshot.data!.docs
                .map((doc) => doc.data())
                .where((user) => user['uid'] != currentUserId)
                .toList();
        if (users.isEmpty) {
          return const Center(child: Text('유저 목록이 없습니다.'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                users[index]['name'] ??
                    '${users[index]['email'].split('@')[0]}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(users[index]['email'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.chat, size: 32, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () {
                      AppRouter.push(
                        VideoMeeting(calleeUid: users[index]['uid']),
                      );
                    },
                    icon: Icon(
                      Icons.video_camera_front,
                      size: 32,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
