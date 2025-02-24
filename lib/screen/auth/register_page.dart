import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample_reels/component/auth_service.dart';
import 'package:sample_reels/screen/profile/profile.dart'; // 遷移先をimport
import 'package:sample_reels/screen/auth/login.dart'; // ログイン画面をimport（パスを合わせてください）

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isRegistering = false; // 🔹 ボタン連打防止用

  void _register() async {
    if (_isRegistering) return; // 🔹 二重登録防止
    setState(() {
      _isRegistering = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (email.isEmpty || password.isEmpty) {
      print("⚠️ メールアドレスとパスワードを入力してください");
      setState(() {
        _isRegistering = false;
      });
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      print("⚠️ メールアドレスの形式が正しくありません: $email");
      setState(() {
        _isRegistering = false;
      });
      return;
    }

    if (password.length < 6) {
      print("⚠️ パスワードは6文字以上で入力してください");
      setState(() {
        _isRegistering = false;
      });
      return;
    }

    final user = await _authService.registerUser(email, password);
    if (user != null) {
      print("✅ ユーザー登録成功: ${user.uid}");

      // 🔹 Firestore に `users` ドキュメントを作成
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': '未設定',
          'age': 18,
          'sex': '未設定',
          'sexualPreference': 'どちらでも',
          'createdAt': Timestamp.now(),
        });

        print("✅ Firestore にユーザー情報を保存");

        // 成功したら ProfilePage に遷移
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      } catch (e) {
        print("❌ Firestore への保存に失敗: $e");
      }
    } else {
      print("❌ ユーザー登録に失敗しました");
    }

    setState(() {
      _isRegistering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ユーザー登録'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 真ん中に配置
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'メールアドレス'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isRegistering ? null : _register, // 🔹 保存中はボタン無効化
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: _isRegistering
                    ? CircularProgressIndicator(
                        color: Colors.white) // 🔹 ローディング表示
                    : Text('登録する'),
              ),
              SizedBox(height: 10),
              // ★ログイン画面への遷移ボタン
              TextButton(
                onPressed: () {
                  // ログイン画面へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('既にアカウントをお持ちの場合はこちら'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
