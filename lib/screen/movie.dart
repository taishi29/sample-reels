import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sample_reels/component/side_buttons.dart'; // いいねボタン用
import 'package:sample_reels/component/image_slide.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => MoviePageState();
}

class MoviePageState extends State<MoviePage> {
  bool _isLiked = false;
  int _likeCount = 0;
  late VideoPlayerController _controller;
  bool _isControllerInitialized = false;

  final List<String> imageUrls = [
    'https://pics.dmm.co.jp/digital/video/sone00614/sone00614jp-1.jpg',
    'https://pics.dmm.co.jp/digital/video/sone00614/sone00614jp-2.jpg',
    'https://pics.dmm.co.jp/digital/video/sone00614/sone00614jp-3.jpg',
    'https://pics.dmm.co.jp/digital/video/sone00614/sone00614jp-4.jpg',
    'https://pics.dmm.co.jp/digital/video/sone00614/sone00614jp-5.jpg',
    'https://pics.dmm.co.jp/digital/video/sone00614/sone00614jp-6.jpg',
    'https://pics.dmm.co.jp/digital/video/sone00614/sone00614jp-7.jpg',
    'https://pics.dmm.co.jp/digital/video/sone00614/sone00614jp-8.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  // **動画を初期化**
  void _initializeVideo() {
    _controller = VideoPlayerController.network(
      'https://cc3001.dmm.co.jp/litevideo/freepv/s/son/sone00614/sone00614mhb.mp4', // ✅ ここに直接動画URLを埋め込む
    )..initialize().then((_) {
        setState(() {
          _isControllerInitialized = true;
        });
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // **いいねボタンの処理**
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
          // **動画の埋め込み（背景に表示）**
          Column(
            children: [
              Expanded(
                flex: 1, // 画面の1/3を使う
                child: _isControllerInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
              Expanded(
                flex: 2, // 画面の2/3を使う
                child: ImageSlider(imageUrls: imageUrls),
              ),
            ],
          ),

          // **右下のボタン群（いいね機能など）**
          RightSideButtons(
            onLikePressed: _toggleLike,
            isLiked: _isLiked,
            likeCount: _likeCount,
          ),
        ],
      ),
    );
  }
}
