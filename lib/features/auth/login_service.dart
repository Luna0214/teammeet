import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teammeet/core/model/user_model.dart';
import '../home/home_page.dart';
import '../../shared/app_router.dart';

class LoginService {
  static Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    // debugPrint('Firebase Auth email: $email, password: $password');

    // 입력값 검증
    if (email.isEmpty || password.isEmpty) {
      showErrorDialog(context, '입력 오류', '이메일과 비밀번호를 모두 입력해주세요.');
      return;
    }

    // 이메일 형식 검증
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      showErrorDialog(context, '이메일 형식 오류', '올바른 이메일 형식을 입력해주세요.');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      //debugPrint('Firebase Auth userCredential: ${userCredential.user?.uid}');

      if (context.mounted && userCredential.user != null) {
        await isCurrentUserInDatabase(userCredential.user!);
        AppRouter.pushAndRemoveUntil(const HomePage());
      } else {
        //debugPrint('Firebase Auth userCredential: ${userCredential.user?.uid}');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      String errorMessage = _getErrorMessage(e.code);
      if (context.mounted) {
        showErrorDialog(context, '로그인 실패', errorMessage);
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      if (context.mounted) {
        showErrorDialog(context, '오류', '예상치 못한 오류가 발생했습니다: $e');
      }
    }
  }

  static String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'user-not-found':
        return '해당 이메일로 등록된 사용자를 찾을 수 없습니다.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'user-disabled':
        return '해당 계정은 비활성화되었습니다.';
      case 'too-many-requests':
        return '너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      default:
        return '로그인 중 오류가 발생했습니다. (오류 코드: $errorCode)';
    }
  }

  static void showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.error, size: 40, color: Colors.red),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> isCurrentUserInDatabase(User currentUser) async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
    if (userDoc.exists) {
      // debugPrint('Existing User: ${currentUser.uid}');
      return;
    } else {
      FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
        'uid': currentUser.uid,
        'email': currentUser.email,
        'name': currentUser.displayName,
        'profileImage': '',
        'createdAt': DateTime.now(),
      });
      // debugPrint('New User: ${currentUser.uid}');
    }
  }

  static Future<UserModel?> getUserInfo(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return UserModel.fromJson(userDoc.data()!);
    }
    return null;
  }

  static Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('로그아웃 중 오류 발생: $e');
      // 재시도
      await FirebaseAuth.instance.signOut();
    }
  }
}
