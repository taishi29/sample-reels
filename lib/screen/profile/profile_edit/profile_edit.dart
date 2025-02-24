import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample_reels/screen/profile/profile_edit/age_edit.dart';
import 'package:sample_reels/screen/profile/profile_edit/name_edit.dart';
import 'package:sample_reels/screen/profile/profile_edit/sex_edit.dart';
import 'package:sample_reels/screen/profile/profile_edit/sexual_preference_edit.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => ProfileEditPageState();
}

class ProfileEditPageState extends State<ProfileEditPage> {
  String name = '';
  int age = 0;
  String sex = '';
  String sexualPreference = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          name = doc['name'] ?? '';
          age = doc['age'] ?? 0;
          sex = doc['sex'] ?? '男性'; // デフォルト値
          sexualPreference = doc['sexualPreference'] ?? 'どちらでも';
        });
      }
    }
  }

  Future<void> _updateName() async {
    final newName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NameEditPage(name: name)),
    );
    if (newName != null) {
      setState(() {
        name = newName;
      });
    }
  }

  Future<void> _updateAge() async {
    final newAge = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgeEditPage(age: age)),
    );
    if (newAge != null) {
      setState(() {
        age = newAge;
      });
    }
  }

  Future<void> _updateSex() async {
    final newSex = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SexEditPage(sex: sex)),
    );
    if (newSex != null) {
      setState(() {
        sex = newSex;
      });
    }
  }

  Future<void> _updateSexualPreference() async {
    final newPreference = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SexualPreferenceEditPage(sexualPreference: sexualPreference)),
    );
    if (newPreference != null) {
      setState(() {
        sexualPreference = newPreference;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'プロフィール編集',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // 画像変更処理
                    },
                    child: CircleAvatar(
                      radius: 50,
                      child:
                          Icon(Icons.person, color: Colors.white60, size: 30),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {},
                    child: Text('写真を変更', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
            Divider(),
            ProfileTile(
              title: '名前',
              value: name,
              onTap: _updateName,
            ),
            ProfileTile(
              title: '年齢',
              value: age.toString(),
              onTap: _updateAge,
            ),
            ProfileTile(
              title: '性別',
              value: sex,
              onTap: _updateSex,
            ),
            ProfileTile(
              title: '性的指向',
              value: sexualPreference,
              onTap: _updateSexualPreference,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  ProfileTile({required this.title, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
