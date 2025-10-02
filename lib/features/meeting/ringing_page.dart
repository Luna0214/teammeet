import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teammeet/core/model/user_model.dart';
import 'package:teammeet/features/auth/login_service.dart';

class RingingPage extends StatefulWidget {
  final String callerUid;
  const RingingPage({super.key, required this.callerUid});

  @override
  State<RingingPage> createState() => _RingingPageState();
}

class _RingingPageState extends State<RingingPage> {
  UserModel? caller;

  @override
  void initState() {
    super.initState();
    initCaller();
  }

  void initCaller() async {
    caller =
        await LoginService.getUserInfo(widget.callerUid) ??
        UserModel(
          uid: 'unknown',
          email: 'unknown',
          name: '알 수 없는 사용자',
          profileImage: '',
          createdAt: Timestamp.now(),
        );
  }

  @override
  Widget build(BuildContext context) {
    String profileImage = caller?.profileImage ?? '';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('비디오 미팅 요청'),
      ),
      body: Column(
        children: [
          Text(
            '${caller?.name}',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          Text(
            '${caller?.email}',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child:
                profileImage != ''
                    ? CircleAvatar(
                      backgroundImage: NetworkImage(profileImage),
                      radius: 150,
                    )
                    : CircleAvatar(
                      radius: 150,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 180,
                        color: Colors.grey[600],
                      ),
                    ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.1,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.green,
                  child: IconButton(
                    onPressed: () {
                      debugPrint('call accepted');
                    },
                    icon: Icon(Icons.call, size: 35),
                    color: Colors.white,
                  ),
                ),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    onPressed: () {
                      debugPrint('call ended');
                    },
                    icon: Icon(Icons.call_end, size: 35),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
