import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:sample_reels/component/side_buttons.dart';
import 'package:sample_reels/component/image_slide.dart';

class DmmMoviePage extends StatefulWidget {
  const DmmMoviePage({super.key});

  @override
  State<DmmMoviePage> createState() => DmmMoviePageState();
}

class DmmMoviePageState extends State<DmmMoviePage> {
  List<bool> isLikedList = []; // 各動画ごとの「いいね」状態
  List<int> likeCountList = []; // 各動画ごとの「いいね」数
  List<String> videoUrls = [];
  List<List<String>> imageSlides = [];
  List<String> shareUrls = [];
  List<String> docIds = []; // Firestore のドキュメントIDリスト
  List<VideoPlayerController> _controllers = [];
  final PageController _pageController = PageController();
  int _currentIndex = 0;
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
          .collection('DmmVideo')
          .get();

      final newVideoUrls = <String>[];
      final newImageSlides = <List<String>>[];
      final newLikeCountList = <int>[];
      final newIsLikedList = <bool>[];
      final newDocIds = <String>[];

      for (var doc in snapshot.docs) {
        if (!doc.data().containsKey('サンプル動画URL') ||
            !doc.data().containsKey('サンプル画像')) {
          print("⚠️ 必要なフィールドが見つかりません: ${doc.data().keys}");
          continue;
        }

        String videoUrl = doc['サンプル動画URL'];
        List<String> images = List<String>.from(doc['サンプル画像']);
        String productPageUrl = doc['url']; // 商品ページURL
        int goodCount = doc['good'] ?? 0;
        String docId = doc.id;

        var controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await controller.initialize();

        newVideoUrls.add(videoUrl);
        newImageSlides.add(images);
        newLikeCountList.add(goodCount);
        newIsLikedList.add(false); // 初期状態は false
        newDocIds.add(docId);

        setState(() {
          videoUrls = newVideoUrls;
          imageSlides = newImageSlides;
          likeCountList = newLikeCountList;
          isLikedList = newIsLikedList;
          docIds = newDocIds;
          shareUrls.add(productPageUrl);
          _controllers.add(controller);

          if (_controllers.length == 1) {
            controller.play();
            controller.setLooping(true);
          }
        });

        controller.addListener(() {
          setState(() {});
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

  void _toggleLike(String docId, int index) async {
    setState(() {
      isLikedList[index] = !isLikedList[index];
      likeCountList[index] += isLikedList[index] ? 1 : -1;
    });

    try {
      var docRef = FirebaseFirestore.instance
          .collection('Products')
          .doc('m9BJjrgbEY3UW6sARIXF')
          .collection('DmmVideo')
          .doc(docId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        int currentGood = snapshot['good'] ?? 0;
        int newGood = isLikedList[index] ? currentGood + 1 : currentGood - 1;

        transaction.update(docRef, {'good': newGood});
      });

      // Firestore にユーザーのいいね状態を保存
      await FirebaseFirestore.instance
          .collection('Users')
          .doc('userId') // TODO: 実際のユーザーIDを設定
          .collection('LikedVideos')
          .doc(docId)
          .set({'liked': isLikedList[index]});
    } catch (e) {
      print("Error updating good count: $e");
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controllers[_currentIndex].setVolume(_isMuted ? 0 : 1);
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controllers[_currentIndex].value.isPlaying) {
        _controllers[_currentIndex].pause();
      } else {
        _controllers[_currentIndex].play();
      }
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
                return GestureDetector(
                  onTap: _togglePlayPause,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _controllers[index].value.isInitialized
                                ? Stack(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: _controllers[index]
                                            .value
                                            .aspectRatio,
                                        child: VideoPlayer(_controllers[index]),
                                      ),
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
                                    child: CircularProgressIndicator(),
                                  ),
                          ),
                          Expanded(
                            flex: 2,
                            child: ImageSlider(imageUrls: imageSlides[index]),
                          ),
                        ],
                      ),
                      RightSideButtons(
                        onLikePressed: () => _toggleLike(docIds[index], index),
                        isLiked: isLikedList[index],
                        likeCount: likeCountList[index],
                        shereUrl: shareUrls[index],
                        docId: docIds[index],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
