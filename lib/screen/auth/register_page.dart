import 'package:flutter/material.dart';
import 'package:sample_reels/component/auth_service.dart';
import 'package:sample_reels/screen/profile.dart'; // 遷移先をimport

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (email.isEmpty || password.isEmpty) {
      print("⚠️ メールアドレスとパスワードを入力してください");
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      print("⚠️ メールアドレスの形式が正しくありません: $email");
      return;
    }

    if (password.length < 6) {
      print("⚠️ パスワードは6文字以上で入力してください");
      return;
    }

    final user = await _authService.registerUser(email, password);
    if (user != null) {
      print("✅ ユーザー登録成功: ${user.uid}");

      // 成功したら `HomePage` に遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      print("❌ ユーザー登録に失敗しました");
    }
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
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('登録する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
