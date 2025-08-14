import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_page.dart';
import 'login_page.dart';

class LoginService {
  static Future<void> login(String email, String password, BuildContext context) async {
    debugPrint('Firebase Auth email: $email, password: $password');
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    debugPrint('Firebase Auth userCredential: ${userCredential.user?.uid}');

    // When sucess, enroute to home page
    if (context.mounted && userCredential.user != null) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
    } else {
      debugPrint('Firebase Auth userCredential: ${userCredential.user?.uid}');
    }
  }

  static Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      debugPrint('Logout Failed User: ${user.uid}');
    } else {
      debugPrint('User Logout Successfully');
    }

    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}