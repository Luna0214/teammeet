import 'package:flutter/material.dart';

class ChatroomList extends StatefulWidget {
  const ChatroomList({super.key});

  @override
  State<ChatroomList> createState() => _ChatroomListState();
}

class _ChatroomListState extends State<ChatroomList> {
  final List<Map<String, dynamic>> chatrooms = [
    {'id': 1, 'name': 'John Doe', 'email': 'john.doe@example.com', 'lastMessage': 'Hello, how are you?', 'lastMessageTime': '2025-01-01 12:00:00'},
    {'id': 2, 'name': 'Jane Smith', 'email': 'jane.smith@example.com', 'lastMessage': 'I\'m fine, thank you.', 'lastMessageTime': '2025-01-01 12:00:00'},
    {'id': 3, 'name': 'Alice Johnson', 'email': 'alice.johnson@example.com', 'lastMessage': 'I\'m busy, sorry.', 'lastMessageTime': '2025-01-01 12:00:00'},
  ];

  @override
  void initState() {
    super.initState();
    // Fireabase 채팅방 목록 가져오기
    // chatrooms.add({'id': 4, 'name': 'John Doe', 'email': 'john.doe@example.com', 'lastMessage': 'Hello, how are you?', 'lastMessageTime': '2025-01-01 12:00:00'});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chatrooms.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(chatrooms[index]['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
          subtitle: Text(chatrooms[index]['lastMessage'], style: const TextStyle(fontSize: 14,),),
          trailing: Text(chatrooms[index]['lastMessageTime'], style: const TextStyle(fontSize: 12,),),
        );
      },
    );
  }
}