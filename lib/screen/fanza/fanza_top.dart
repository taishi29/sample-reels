import 'package:flutter/material.dart';
import 'package:sample_reels/screen/dmm/dmm_top.dart';

// 各スクリーンのimport
import 'package:sample_reels/screen/fanza/fanza_manga.dart';
import 'package:sample_reels/screen/fanza/fanza_movie.dart';
import 'package:sample_reels/screen/fanza/fanza_voice.dart';

// componentのimport
import 'package:sample_reels/component/bottom_bar.dart';

class FanzaTopPage extends StatefulWidget {
  const FanzaTopPage({super.key});

  @override
  State<FanzaTopPage> createState() => _FanzaTopPageState();
}

class _FanzaTopPageState extends State<FanzaTopPage> {
  int _currentIndex = 0; // 🔹 上部のタブのインデックス
  int _selectedIndex = 1; // 🔹 BottomNavigationBar のインデックス（1 = FANZA）

  final PageController _pageController = PageController();

  final List<String> _tabs = ["漫画", "動画", "ボイス"];

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
          transitionDuration: const Duration(milliseconds: 500), // アニメーション時間
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // -----------------------
            // 🔹 上部のカテゴリタブ
            // -----------------------
            Row(
              children: List.generate(_tabs.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = index; // 🔹 上部タブの状態を更新
                      });
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: _currentIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            // -----------------------
            // 🔹 PageView（コンテンツ表示）
            // -----------------------
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // 🔹 横スクロールを無効化
                children: const [
                  FanzaMangaPage(),
                  FanzaMoviePage(),
                  FanzaVoicePage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        onItemTapped: _onItemTapped, // 🔹 タップされたら `_onItemTapped()` を実行
        currentIndex: _selectedIndex, // 🔹 現在の選択中のインデックスを渡す
      ),
    );
  }
}
