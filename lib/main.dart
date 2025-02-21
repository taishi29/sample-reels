import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Firebaseをインポート
import 'package:sample_reels/screen/fanza/fanza_top.dart';
import 'firebase_options.dart'; // ✅ Firebase 設定ファイル

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
      title: 'SampleReels',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const FanzaTopPage(),
    );
  }
}
