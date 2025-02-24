import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NameEditPage extends StatefulWidget {
  final String name;
  const NameEditPage({super.key, required this.name});

  @override
  State<NameEditPage> createState() => _NameEditPageState();
}

class _NameEditPageState extends State<NameEditPage> {
  late TextEditingController _controller;
  bool _isSaving = false; // 🔹 ボタン連打防止用フラグ

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  Future<void> _updateName() async {
    if (_isSaving) return; // 🔹 二重タップ防止
    setState(() {
      _isSaving = true;
    });

    String newName = _controller.text.trim();

    // 🔹 空白や変更なしの場合は保存しない
    if (newName.isEmpty || newName == widget.name) {
      Navigator.pop(context, widget.name); // 🔹 変更なしで前の画面に戻る
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'name': newName});
      } catch (e) {
        print("🔥 Firestore エラー: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("エラーが発生しました")),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
    }

    Navigator.pop(context, newName); // 🔹 保存成功後に前の画面へ戻る
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('名前を編集')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '名前',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _updateName, // 🔹 ボタン連打防止
              child: _isSaving
                  ? CircularProgressIndicator(
                      color: Colors.white) // 🔹 ローディング表示
                  : Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
