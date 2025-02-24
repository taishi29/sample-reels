import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
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


  // ここからが追加：ログイン用のメソッド
  Future<User?> signInUser(String email, String password) async {
    try {
      // FirebaseAuth のサインインメソッドを利用
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // 成功時には User を返す
    } on FirebaseAuthException catch (e) {
      // FirebaseAuthException の場合は code で内容を判別
      if (e.code == 'user-not-found') {
        print('❌ ユーザーが見つかりません。メールアドレスを確認してください。');
      } else if (e.code == 'wrong-password') {
        print('❌ パスワードが間違っています。');
      } else {
        print('❌ ログインエラー: ${e.message}');
      }
      return null;
    } catch (e) {
      // それ以外のエラー想定
      print("❌ 予期せぬエラー: $e");
      return null;
    }
  }
}





