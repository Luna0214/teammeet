import 'package:flutter/material.dart';
import '../auth/login_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Widget _bodyWidget() {
    return const Center(child: Text('Home page testing'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () => LoginService.logout(context),
            icon: const Icon(Icons.logout, color: Colors.white,),
          ),
        ],
      ),
      body: _bodyWidget(),
    );
  }
}