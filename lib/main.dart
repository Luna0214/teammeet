import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:teammeet/features/auth/login_page.dart';
import 'package:teammeet/shared/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'teammeet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const LoginPage(),
    );
  }
}
