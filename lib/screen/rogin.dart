import 'package:flutter/material.dart';
import 'package:sample_reels/component/auth_service.dart';
import 'package:sample_reels/screen/profile.dart'; // ログイン後の画面

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _errorMessage;
  bool _isPasswordVisible = false; // パスワード表示切り替え

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _errorMessage = null; // エラーメッセージをリセット
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "⚠️ メールアドレスとパスワードを入力してください";
      });
      return;
    }

    try {
      final user = await _authService.loginUser(email, password);
      if (user != null) {
        print("✅ ログイン成功: ${user.uid}");

        // `ProfilePage` に遷移（戻るボタンを無効化）
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      } else {
        setState(() {
          _errorMessage = "❌ メールアドレスまたはパスワードが間違っています";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "❌ ユーザーが存在しません";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ログイン',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible, // パスワードの可視性を切り替え
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
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('ログイン'),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  'アカウントをお持ちでないですか？ 登録',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
