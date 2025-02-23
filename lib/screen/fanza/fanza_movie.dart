import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:sample_reels/component/side_buttons.dart'; // いいねボタン用
import 'package:sample_reels/component/image_slide.dart'; // ✅ 画像スライダー

class FanzaMoviePage extends StatefulWidget {
  const FanzaMoviePage({super.key});

  @override
  State<FanzaMoviePage> createState() => FanzaMoviePageState();
}

class FanzaMoviePageState extends State<FanzaMoviePage> {
  bool _isLiked = false;
  int _likeCount = 0;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<String> videoUrls = [];
  List<List<String>> imageSlides = [];
  List<VideoPlayerController> _controllers = [];
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _fetchVideosFromFirestore();
  }

  Future<void> _fetchVideosFromFirestore() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .doc('m9BJjrgbEY3UW6sARIXF')
          .collection('FanzaMov')
          .get();

      for (var doc in snapshot.docs) {
        print("取得したデータ: ${doc.data()}");

        if (!doc.data().containsKey('サンプル動画URL') ||
            !doc.data().containsKey('サンプル画像')) {
          print("⚠️ 必要なフィールドが見つかりません: ${doc.data().keys}");
          continue;
        }

        String videoUrl = doc['サンプル動画URL'];
        List<String> images = List<String>.from(doc['サンプル画像']);

        var controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await controller.initialize();

        setState(() {
          videoUrls.add(videoUrl);
          imageSlides.add(images);
          _controllers.add(controller);

          if (_controllers.length == 1) {
            controller.play();
            controller.setLooping(true);
          }
        });
      }
    } catch (e) {
      print("Error fetching videos: $e");
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controllers[_currentIndex].setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: videoUrls.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: videoUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _controllers[_currentIndex].pause();
                  _currentIndex = index;
                  _controllers[_currentIndex].play();
                  _controllers[_currentIndex].setVolume(_isMuted ? 0 : 1);
                });
              },
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    // **動画 + 画像スライド**
                    Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _controllers[index].value.isInitialized
                              ? Stack(
                                  children: [
                                    AspectRatio(
                                      aspectRatio:
                                          _controllers[index].value.aspectRatio,
                                      child: VideoPlayer(_controllers[index]),
                                    ),

                                    // **右下端の消音ボタン**
                                    Positioned(
                                      right: 16,
                                      bottom: 16,
                                      child: IconButton(
                                        icon: Icon(
                                          _isMuted
                                              ? Icons.volume_off
                                              : Icons.volume_up,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: _toggleMute,
                                      ),
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: CircularProgressIndicator()),
                        ),
                        Expanded(
                          flex: 2,
                          child: ImageSlider(imageUrls: imageSlides[index]),
                        ),
                      ],
                    ),
                    // **右側のいいねボタン**
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
