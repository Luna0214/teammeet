import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {


    Widget _bodyWidget() {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('TeamMeet', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),),
            SizedBox(height: 50,),
            Text('로그인', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  TextField(
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
                ],
              ),
            ),
            
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {},
              child: Text('로그인'),
            ),
            SizedBox(height: 100),
            Text('소셜 로그인', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('구글'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('카카오'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('네이버'),
                ),
              ],
            ),
          ],
        ),
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
      body: _bodyWidget(),
    );
  }
}