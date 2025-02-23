import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 ユーザー登録処理（Firebase Authentication）
  Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('❌ パスワードが弱すぎます。6文字以上にしてください。');
      } else if (e.code == 'email-already-in-use') {
        print('❌ そのメールアドレスは既に登録されています。');
      } else {
        print('❌ エラー: ${e.message}');
      }
      return null;
    } catch (e) {
      print("❌ 予期せぬエラー: $e");
      return null;
    }
  }

  /// 🔹 ログイン処理
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('❌ ユーザーが見つかりません');
      } else if (e.code == 'wrong-password') {
        print('❌ パスワードが間違っています');
      } else {
        print('❌ エラー: ${e.message}');
      }
      return null;
    } catch (e) {
      print("❌ 予期せぬエラー: $e");
      return null;
    }
  }

  /// 🔹 ログアウト処理
  Future<void> logout() async {
    await _auth.signOut();
    print("✅ ログアウトしました");
  }

  /// 🔹 現在ログインしているユーザーを取得
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
