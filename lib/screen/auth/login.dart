import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample_reels/component/auth_service.dart';
import 'package:sample_reels/screen/profile.dart';  // ログイン後に遷移するページ

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. 入力バリデーション
    if (email.isEmpty || password.isEmpty) {
      print("⚠️ メールアドレスとパスワードを入力してください");
      return;
    }

    // 2. ログイン実行（AuthService の signInUser()）
    final User? user = await _authService.signInUser(email, password);

    if (user != null) {
      // 3. 成功時
      print("✅ ログイン成功: ${user.uid}");
      // ProfilePage など、ログイン後に表示したい画面へ遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      // 4. 失敗時
      print("❌ ログインに失敗しました");
    }
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
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                ),
                child: Text('ログイン'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
