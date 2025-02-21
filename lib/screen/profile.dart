import 'package:flutter/material.dart';
// スクリーンのimport
import 'package:sample_reels/screen/dmm/dmm_top.dart';
import 'package:sample_reels/screen/fanza/fanza_top.dart';
// componentのimport
import 'package:sample_reels/component/bottom_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; // 🔹 BottomNavigationBar のインデックス（1 = FANZA）

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
          transitionDuration: const Duration(milliseconds: 250), // アニメーション時間
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
          transitionDuration: const Duration(milliseconds: 250), // アニメーション時間
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
        title: const Text(
          'ヒカキン',
          style: TextStyle(
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
          // フォロー数といいね数
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: const [
                  Text(
                    "28",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "フォロー中",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Column(
                children: const [
                  Text(
                    "3",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "いいね",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // プロフィール編集ボタン
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: () {},
            child: const Text("プロフィールを編集"),
          ),
          const SizedBox(height: 10),
          // グリッドビュー（3x3）
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3列
                  crossAxisSpacing: 4.0, // 横方向の間隔
                  mainAxisSpacing: 4.0, // 縦方向の間隔
                  childAspectRatio: 1.0, // 正方形のタイル
                ),
                itemCount: 9, // 9つのタイル
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
        onItemTapped: _onItemTapped, // 🔹 タップされたら `_onItemTapped()` を実行
        currentIndex: _selectedIndex, // 🔹 現在の選択中のインデックスを渡す
      ),
    );
  }
}
