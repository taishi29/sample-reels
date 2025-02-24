import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample_reels/screen/profile/profile.dart';
import 'package:sample_reels/screen/auth/register_page.dart';
import 'firebase_options.dart'; // Firebase 設定ファイル

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Firebase 初期化前に必要
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ Firebase 設定を適用
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SampleReels',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const AuthCheck(), // 🔹 ログイン状態を確認するウィジェット
    );
  }
}

// 🔹 ログイン状態をチェックするウィジェット
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // 🔹 ローディング表示
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return ProfilePage(); // 🔹 ログイン済みなら ProfilePage へ
        }
        return RegisterPage(); // 🔹 未ログインなら RegisterPage へ
      },
    );
  }
}
