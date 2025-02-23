import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:sample_reels/component/side_buttons.dart'; // いいねボタン用
import 'package:sample_reels/component/image_slide.dart'; // ✅ 画像スライダー

class DmmMoviePage extends StatefulWidget {
  const DmmMoviePage({super.key});

  @override
  State<DmmMoviePage> createState() => DmmMoviePageState();
}

class DmmMoviePageState extends State<DmmMoviePage> {
  bool _isLiked = false; // いいね状態を管理する変数
  int _likeCount = 0; // いいねの数を管理する変数
  final PageController _pageController = PageController(); // ✅ 縦スクロール用
  int _currentIndex = 0; // ✅ 現在の動画のインデックス

  // Firestore から取得したデータを格納するリスト
  List<String> videoUrls = []; // 動画URLリスト
  List<List<String>> imageSlides = []; // 画像スライドリスト
  List<VideoPlayerController> _controllers = []; // 動画コントローラーリスト

  List<String> shareUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchVideosFromFirestore(); // Firestore からデータを取得
  }

  // **Firestore から動画データを取得**
  Future<void> _fetchVideosFromFirestore() async {
    try {
      // Firestore から `FanzaMov` コレクションのデータを取得
      var snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .doc('m9BJjrgbEY3UW6sARIXF') // ✅ 固定のドキュメントID（プロジェクトに応じて変更）
          .collection('FanzaMov')
          .get();

      // 取得したドキュメントをループ処理
      for (var doc in snapshot.docs) {
        print("取得したデータ: ${doc.data()}"); // ✅ デバッグ用

        // **Firestore に必要なフィールドがあるかチェック**
        if (!doc.data().containsKey('サンプル動画URL') ||
            !doc.data().containsKey('サンプル画像')) {
          print("⚠️ 必要なフィールドが見つかりません: ${doc.data().keys}");
          continue; // データが不完全ならスキップ
        }

        // Firestore から動画URL & 画像URLを取得
        String videoUrl = doc['サンプル動画URL'];
        List<String> images = List<String>.from(doc['サンプル画像']);
        String productPageUrl = doc['url']; // 商品ページURLを取得

        // **動画コントローラーの作成と初期化**
        var controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await controller.initialize(); // ✅ 初期化処理（非同期）

        // **UI を更新**
        setState(() {
          videoUrls.add(videoUrl); // ✅ 取得した動画URLをリストに追加
          imageSlides.add(images); // ✅ 取得した画像リストを追加
          _controllers.add(controller); // ✅ 動画コントローラーをリストに追加
          shareUrls.add(productPageUrl);

          // 最初の動画は自動再生 & ループ設定
          if (_controllers.length == 1) {
            controller.play();
            controller.setLooping(true);
          }
        });
      }
    } catch (e) {
      print("Error fetching videos: $e"); // エラーハンドリング
    }
  }

  @override
  void dispose() {
    // **メモリ解放**
    for (var controller in _controllers) {
      controller.dispose(); // ✅ 各動画コントローラーを破棄
    }
    _pageController.dispose(); // ✅ スクロールのコントローラーを破棄
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

      // **データ取得中はローディング表示**
      body: videoUrls.isEmpty
          ? const Center(child: CircularProgressIndicator()) // ✅ データ取得中
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical, // ✅ 縦スクロール
              itemCount: videoUrls.length, // ✅ Firestore から取得したデータ数
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
                    // **動画 + 画像スライドのレイアウト**
                    Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _controllers[index].value.isInitialized
                              ? AspectRatio(
                                  aspectRatio:
                                      _controllers[index].value.aspectRatio,
                                  child: VideoPlayer(_controllers[index]),
                                )
                              : const Center(
                                  child:
                                      CircularProgressIndicator()), // ✅ ローディング表示
                        ),
                        Expanded(
                          flex: 2,
                          child: ImageSlider(
                              imageUrls: imageSlides[index]), // ✅ 画像スライダー
                        ),
                      ],
                    ),

                    // **いいねボタン（右下）**
                    RightSideButtons(
                      onLikePressed: _toggleLike,
                      isLiked: _isLiked,
                      likeCount: _likeCount,
                      shereUrl: shareUrls[index],
                    ),
                  ],
                );
              },
            ),
    );
  }
}
