import 'package:flutter/material.dart';
import 'package:sample_reels/component/auth_service.dart';
import 'package:sample_reels/screen/profile.dart'; // 遷移先

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _errorMessage;

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 入力バリデーション
    final error = _validateInput(email, password);
    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
      return;
    }

    // Firebaseでユーザー登録
    final user = await _authService.registerUser(email, password);
    if (user != null) {
      print("✅ ユーザー登録成功: ${user.uid}");

      // `ProfilePage` に遷移（戻るボタンを無効化）
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      setState(() {
        _errorMessage = "❌ ユーザー登録に失敗しました";
      });
    }
  }

  /// 入力バリデーション（エラーがある場合はエラーメッセージを返す）
  String? _validateInput(String email, String password) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (email.isEmpty || password.isEmpty) {
      return "⚠️ メールアドレスとパスワードを入力してください";
    }
    if (!emailRegex.hasMatch(email)) {
      return "⚠️ メールアドレスの形式が正しくありません";
    }
    if (password.length < 6) {
      return "⚠️ パスワードは6文字以上で入力してください";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ユーザー登録'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'メールアドレス',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
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
