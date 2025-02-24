import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgeEditPage extends StatefulWidget {
  final int age;
  const AgeEditPage({super.key, required this.age});

  @override
  State<AgeEditPage> createState() => _AgeEditPageState();
}

class _AgeEditPageState extends State<AgeEditPage> {
  int selectedAge = 18; // 初期値を18歳に設定

  @override
  void initState() {
    super.initState();
    selectedAge = widget.age;
  }

  Future<void> _updateAge() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'age': selectedAge});
    }
    Navigator.pop(context, selectedAge); // 🔹 変更した年齢を渡して前の画面へ戻る
  }

  void _showAgePicker() {
    int tempSelectedAge = selectedAge; // 🔹 一時変数を作成
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "年齢を選択",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  physics: FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    tempSelectedAge = index + 18; // 🔹 一時変数を更新
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      return Center(
                        child: Text(
                          (index + 18).toString(),
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    },
                    childCount: 100, // 18歳から117歳まで選べる
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedAge = tempSelectedAge; // 🔹 `selectedAge` を更新
                  });
                  Navigator.pop(context); // 🔹 ピッカーを閉じる
                },
                child: Text('選択'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('年齢を編集')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showAgePicker,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$selectedAge 歳',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateAge, // 🔹 保存時にFirestoreへ更新 & 前の画面へ戻る
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
