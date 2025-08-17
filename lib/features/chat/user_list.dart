import 'package:flutter/material.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final List<Map<String, dynamic>> users = [
    {'id': 1, 'name': 'John Doe', 'email': 'john.doe@example.com'},
    {'id': 2, 'name': 'Jane Smith', 'email': 'jane.smith@example.com'},
    {'id': 3, 'name': 'Alice Johnson', 'email': 'alice.johnson@example.com'},
  ];

  @override
  void initState() {
    super.initState();
    // Fireabase 유저 목록 가져오기
    // users.add({'id': 4, 'name': 'John Doe', 'email': 'john.doe@example.com'});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(users[index]['name']),
          subtitle: Text(users[index]['email']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.chat, size: 32, color: Colors.blue,),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.video_camera_front, size: 32, color: Colors.green,),
              ),
            ],
          )
        );
      },
    );
  }
}