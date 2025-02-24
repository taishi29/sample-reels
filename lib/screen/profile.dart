import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// スクリーンのimport
import 'package:sample_reels/screen/dmm/dmm_top.dart';
import 'package:sample_reels/screen/fanza/fanza_top.dart';
import 'package:sample_reels/screen/profileedit.dart'; // 🔹 profileedit.dart をインポート
// componentのimport
import 'package:sample_reels/component/bottom_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; // 🔹 BottomNavigationBar のインデックス
  String name = "Loading..."; // 初期値
  String introduction = "Loading..."; // 初期値

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Firestoreからデータを取得
  }

  // 🔹 Firestore から `Uid` に対応する `name` と `introduction` を取得
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;

      try {
        DocumentSnapshot userDoc = 
            await FirebaseFirestore.instance.collection('Users').doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            name = userDoc['name'] ?? "No Name";
            introduction = userDoc['introduction'] ?? "No Introduction";
          });
        } else {
          setState(() {
            name = "User not found";
            introduction = "";
          });
        }
      } catch (e) {
        print("🔥 Firestoreエラー: $e");
        setState(() {
          name = "Error loading";
          introduction = "";
        });
      }
    }
  }

  // 🔹 BottomNavigationBar のタップ時の処理
  void _onItemTapped(int index) {
    if (index == 0) {
      // DMMのタブを押したら `DmmTopPage` に遷移
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DmmTopPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const FanzaTopPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
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
        title: Text(
          name, // 🔹 Firestoreから取得した `name` を表示
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // プロフィール画像
          const CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage: NetworkImage(
                'https://pbs.twimg.com/profile_images/1476938674612805637/Z9-fGmey_400x400.jpg'),
            radius: 40,
          ),
          const SizedBox(height: 10),
          // 🔹 Firestore から取得した `introduction` を表示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              introduction,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          // プロフィール編集ボタン
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditPage(),
                ),
              );
            },
            child: const Text("プロフィールを編集"),
          ),
          const SizedBox(height: 10),
          // グリッドビュー（3x3）
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        onItemTapped: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}
