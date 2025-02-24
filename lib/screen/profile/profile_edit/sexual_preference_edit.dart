import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SexualPreferenceEditPage extends StatefulWidget {
  final String sexualPreference;
  const SexualPreferenceEditPage({super.key, required this.sexualPreference});

  @override
  State<SexualPreferenceEditPage> createState() =>
      _SexualPreferenceEditPageState();
}

class _SexualPreferenceEditPageState extends State<SexualPreferenceEditPage> {
  String selectedPreference = 'どちらでも'; // 初期値
  bool _isSaving = false; // 🔹 ボタン連打防止用

  @override
  void initState() {
    super.initState();
    selectedPreference = widget.sexualPreference; // 受け取った値を初期値にする
  }

  Future<void> _updateSexualPreference() async {
    if (_isSaving) return; // 🔹 二重タップ防止
    setState(() {
      _isSaving = true;
    });

    // 🔹 変更がない場合は Firestore に保存しない
    if (selectedPreference == widget.sexualPreference) {
      Navigator.pop(context, widget.sexualPreference);
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'sexualPreference': selectedPreference});
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

    Navigator.pop(context, selectedPreference); // 🔹 保存成功後に前の画面へ戻る
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('性的指向を編集')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("性的指向を選択",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            RadioListTile<String>(
              title: Text("男性"),
              value: "男性",
              groupValue: selectedPreference,
              onChanged: (value) {
                setState(() {
                  selectedPreference = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text("女性"),
              value: "女性",
              groupValue: selectedPreference,
              onChanged: (value) {
                setState(() {
                  selectedPreference = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text("どちらでも"),
              value: "どちらでも",
              groupValue: selectedPreference,
              onChanged: (value) {
                setState(() {
                  selectedPreference = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _isSaving ? null : _updateSexualPreference, // 🔹 保存中はボタン無効化
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
