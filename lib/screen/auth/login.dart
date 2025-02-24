import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample_reels/component/auth_service.dart';
import 'package:sample_reels/screen/profile/profile.dart'; // ログイン後に遷移するページ

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoggingIn = false; // 🔹 ログイン中フラグ

  void _login() async {
    if (_isLoggingIn) return; // 🔹 二重ログイン防止
    setState(() {
      _isLoggingIn = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. 入力バリデーション
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ メールアドレスとパスワードを入力してください")),
      );
      setState(() {
        _isLoggingIn = false;
      });
      return;
    }

    try {
      // 2. Firebase Auth でログイン
      final User? user = await _authService.signInUser(email, password);

      if (user != null) {
        print("✅ ログイン成功: ${user.uid}");

        // 🔹 3. Firestore に `users` ドキュメントがあるかチェック
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // 🔹 もし `users` データがない場合は作成
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'email': email,
            'name': '未設定',
            'age': 18,
            'sex': '未設定',
            'sexualPreference': 'どちらでも',
            'createdAt': Timestamp.now(),
          });
          print("✅ Firestore にユーザーデータを作成");
        }

        // 🔹 4. `ProfilePage` に遷移
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      } else {
        // 🔹 ログイン失敗
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ログインに失敗しました。メールアドレスとパスワードを確認してください。")),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 🔹 Firebase のエラーメッセージを表示
      print("❌ FirebaseAuthException: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${e.message}")),
      );
    } catch (e) {
      print("❌ 予期しないエラー: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ 予期しないエラーが発生しました")),
      );
    }

    setState(() {
      _isLoggingIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'メールアドレス'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true, // パスワードを隠す
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoggingIn ? null : _login, // 🔹 ログイン中はボタン無効化
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                ),
                child: _isLoggingIn
                    ? CircularProgressIndicator(
                        color: Colors.white) // 🔹 ローディング表示
                    : Text('ログイン'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
