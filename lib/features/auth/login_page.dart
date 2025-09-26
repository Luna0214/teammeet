import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'login_service.dart';
import '../../shared/widgets/popup_message.dart';

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2,),
            Text('TeamMeet', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),),
            SizedBox(height: 120,),

            Center(
              child: Padding(
                padding: kIsWeb ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2) : EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: kIsWeb ? 500.0 : 300.0,
                    maxWidth: kIsWeb ? 500.0 : 300.0,
                  ),
                  child: Column(
                    children: [
                      _loginTextField('Email', emailController),
                      SizedBox(height: 20,),
                      _loginTextField('Password', passwordController),
                      SizedBox(height: 20,),
                      SizedBox(
                        height: 60,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ElevatedButton(
                          onPressed: () {
                            LoginService.login(emailController.text, passwordController.text, context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 10,),
            
            SizedBox(height: 100),
            Text('소셜 로그인', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
            SizedBox(height: 30,),
            
            // 소셜 로그인도 중앙 정렬
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: kIsWeb ? 500.0 : 300.0,
                  maxWidth: kIsWeb ? 800.0 : 300.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 구글 로그인
                    GestureDetector(
                      onTap: () {
                        PopupMessage.showMessage(context, '알림', '준비중인 서비스');
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/google_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.g_mobiledata,
                                  size: 30,
                                  color: Colors.red,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    // 카카오톡 로그인
                    GestureDetector(
                      onTap: () {
                        PopupMessage.showMessage(context, '알림', '준비중인 서비스');
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/kakaotalk_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE500),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble,
                                  size: 30,
                                  color: Color(0xFF3C1E1E),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    // 네이버 로그인
                    GestureDetector(
                      onTap: () {
                        PopupMessage.showMessage(context, '알림', '준비중인 서비스');
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/naver_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF03C75A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.text_fields,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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