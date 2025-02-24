import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SexEditPage extends StatefulWidget {
  final String sex;
  const SexEditPage({super.key, required this.sex});

  @override
  State<SexEditPage> createState() => _SexEditPageState();
}

class _SexEditPageState extends State<SexEditPage> {
  String selectedSex = '男性'; // 初期値
  bool _isSaving = false; // 🔹 ボタン連打防止用

  @override
  void initState() {
    super.initState();
    selectedSex = widget.sex; // 受け取った値を初期値にする
  }

  Future<void> _updateSex() async {
    if (_isSaving) return; // 🔹 二重タップ防止
    setState(() {
      _isSaving = true;
    });

    // 🔹 変更がない場合は Firestore に保存しない
    if (selectedSex == widget.sex) {
      Navigator.pop(context, widget.sex);
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'sex': selectedSex});
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

    Navigator.pop(context, selectedSex); // 🔹 保存成功後に前の画面へ戻る
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('性別を編集')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("性別を選択",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            RadioListTile<String>(
              title: Text("男性"),
              value: "男性",
              groupValue: selectedSex,
              onChanged: (value) {
                setState(() {
                  selectedSex = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text("女性"),
              value: "女性",
              groupValue: selectedSex,
              onChanged: (value) {
                setState(() {
                  selectedSex = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text("その他"),
              value: "その他",
              groupValue: selectedSex,
              onChanged: (value) {
                setState(() {
                  selectedSex = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _updateSex, // 🔹 保存中はボタン無効化
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
