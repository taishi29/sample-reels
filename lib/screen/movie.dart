import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sample_reels/component/side_buttons.dart'; // いいねボタン用
import 'package:sample_reels/component/image_slide.dart'; // ✅ 画像スライダーを追加

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => MoviePageState();
}

class MoviePageState extends State<MoviePage> {
  bool _isLiked = false;
  int _likeCount = 0;
  final PageController _pageController = PageController(); // ✅ スクロール管理用
  int _currentIndex = 0; // ✅ 現在の動画のインデックス

  // ✅ 動画URLのリスト
  final List<String> videoUrls = [
    'https://cc3001.dmm.co.jp/litevideo/freepv/s/son/sone00614/sone00614mhb.mp4',
    'https://cc3001.dmm.co.jp/litevideo/freepv/m/mid/mida00036/mida00036mhb.mp4',
    'https://cc3001.dmm.co.jp/litevideo/freepv/m/mid/mida00054/mida00054mhb.mp4',
  ];

  // ✅ 各動画に対応する画像スライドのリスト
  final List<List<String>> imageSlides = [
    [
      'https://pics.dmm.co.jp/digital/video/sone00614/sone00614-1.jpg',
      'https://pics.dmm.co.jp/digital/video/sone00614/sone00614-2.jpg',
      'https://pics.dmm.co.jp/digital/video/sone00614/sone00614-3.jpg',
    ],
    [
      'https://pics.dmm.co.jp/digital/video/mida00036/mida00036-1.jpg',
      'https://pics.dmm.co.jp/digital/video/mida00036/mida00036-2.jpg',
      'https://pics.dmm.co.jp/digital/video/mida00036/mida00036-3.jpg',
    ],
    [
      'https://pics.dmm.co.jp/digital/video/mida00054/mida00054-1.jpg',
      'https://pics.dmm.co.jp/digital/video/mida00054/mida00054-2.jpg',
      'https://pics.dmm.co.jp/digital/video/mida00054/mida00054-3.jpg',
    ],
  ];

  // ✅ 動画コントローラーのリスト
  final List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _initializeVideos();
  }

  // **動画の初期化**
  void _initializeVideos() {
    for (var url in videoUrls) {
      _controllers.add(VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {});
          if (_controllers.length == 1) {
            _controllers[0].play(); // ✅ 最初の動画を自動再生
            _controllers[0].setLooping(true);
          }
        }));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose(); // ✅ メモリ解放
    }
    _pageController.dispose(); // ✅ スクロールのコントローラーも破棄
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
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical, // ✅ 縦スクロール
        itemCount: videoUrls.length,
        onPageChanged: (index) {
          setState(() {
            _controllers[_currentIndex].pause(); // ✅ 前の動画を停止
            _currentIndex = index;
            _controllers[_currentIndex].play(); // ✅ 新しい動画を再生
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              // **動画の埋め込み（上部1/2）**
              Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: _controllers[index].value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _controllers[index].value.aspectRatio,
                            child: VideoPlayer(_controllers[index]),
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),

                  // **画像スライドの埋め込み（下部1/2）**
                  Expanded(
                    flex: 2,
                    child: ImageSlider(
                        imageUrls: imageSlides[index]), // ✅ `ImageSlider` を表示
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
          );
        },
      ),
    );
  }
}
