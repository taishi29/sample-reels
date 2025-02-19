import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 各スクリーンのimport
import 'package:sample_reels/screen/manga.dart';
import 'package:sample_reels/screen/movie.dart';
import 'package:sample_reels/screen/voice.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SampleReels',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const TopPage(),
    );
  }
}

class TopPage extends StatefulWidget {
  const TopPage({super.key});

  @override
  State<TopPage> createState() => TopPageState();
}

class TopPageState extends State<TopPage> {
  int _currentIndex = 0; // ✅ 選択中のタブインデックス
  final PageController _pageController = PageController(); // ✅ ページコントローラー

  // ✅ タブのラベルリスト
  final List<String> _tabs = ["漫画", "動画", "ボイス"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ タブボタン（上部）
            Row(
              children: List.generate(_tabs.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
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
                                : Colors.transparent, // ✅ 選択中のタブの下線
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
                              : FontWeight.normal, // ✅ 選択中のタブを強調
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            // ✅ ページビュー（タップで切り替え）
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: const [
                  MangaPage(),
                  MoviePage(),
                  VoicePage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
