import 'package:flutter/material.dart';
// componentのimport
import 'package:sample_reels/component/side_buttons.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => MoviePageState();
}

class MoviePageState extends State<MoviePage> {
  bool _isLiked = false;
  int _likeCount = 0;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景の黒いコンテナ（仮：動画を入れる場所）
          Column(
            children: [
              Expanded(
                flex: 1, // 画面の1/3を使う
                child: Container(color: Colors.blue),
              ),
              Expanded(
                flex: 2, // 画面の2/3を使う
                child: Container(color: Colors.red),
              ),
            ],
          ),

          // 右下のボタン群（コンポーネントを使用）
          RightSideButtons(
            onLikePressed: _toggleLike, // ✅ 修正：`_toggleLike` を渡す
            isLiked: _isLiked, // ✅ `_isLiked` を渡す
            likeCount: _likeCount, // ✅ `_likeCount` を渡す
          ),
        ],
      ),
    );
  }
}
