import 'package:flutter/material.dart';
import 'login_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    @override
    void initState() {
      super.initState();
      emailController.text = '';
      passwordController.text = '';
    }

    @override
    void dispose() {
      emailController.dispose();
      passwordController.dispose();
      super.dispose();
    }

    Widget _loginTextField(String hintText, TextEditingController controller) {
      return TextField(
        controller: controller,
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        obscureText: hintText == 'Password' ? true : false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      );
    }

    Widget _bodyWidget() {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2,),
            Text('TeamMeet', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),),
            SizedBox(height: 50,),
            Text('로그인', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _loginTextField('Email', emailController),
                  SizedBox(height: 20,),
                  _loginTextField('Password', passwordController),
              SizedBox(height: 20,),              
                ],
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                LoginService.login(emailController.text, passwordController.text, context);
              },
              child: Text('로그인'),
            ),
            SizedBox(height: 80),
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