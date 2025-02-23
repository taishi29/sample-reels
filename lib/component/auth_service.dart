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
}
