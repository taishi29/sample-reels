import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:sample_reels/component/side_buttons.dart';
import 'package:sample_reels/component/image_slide.dart';

class FanzaMoviePage extends StatefulWidget {
  const FanzaMoviePage({super.key});

  @override
  State<FanzaMoviePage> createState() => FanzaMoviePageState();
}

class FanzaMoviePageState extends State<FanzaMoviePage> {
  List<bool> isLikedList = []; // 各動画ごとの「いいね」状態
  List<int> likeCountList = []; // 各動画ごとの「いいね」数
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<String> videoUrls = [];
  List<List<String>> imageSlides = [];
  List<String> shareUrls = [];
  List<VideoPlayerController> _controllers = [];
  bool _isMuted = false;
  List<String> docIds = []; // ドキュメントIDを保存するリストを追加

  @override
  void initState() {
    super.initState();
    _fetchVideosFromFirestore();
  }

  // Firestoreから動画データを取得し、リストに追加する
  Future<void> _fetchVideosFromFirestore() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .doc('5gPSzfeZFiedoFjMgj5d')
          .collection('FanzaMovie')
          .get();

      for (var doc in snapshot.docs) {
        String videoUrl = doc['sampleMovieUrl'];
        List<String> images =
            List<String>.from(doc['sampleImageUrls']['sampleL'] ?? []);
        String productPageUrl = doc['affiliateUrl'];
        String docId = doc.id;
        int goodCount = doc['good'] ?? 0; // Firestore から good 数を取得

        var controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await controller.initialize();

        setState(() {
          videoUrls.add(videoUrl);
          imageSlides.add(images);
          shareUrls.add(productPageUrl);
          _controllers.add(controller);
          docIds.add(docId);
          isLikedList.add(false); // 初期値は false
          likeCountList.add(goodCount); // Firestore から取得した good 数をセット

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
          .doc('5gPSzfeZFiedoFjMgj5d')
          .collection('FanzaMovie')
          .doc(docIds[index]); // `index` に対応するドキュメントを更新

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        int currentGood = snapshot['good'] ?? 0;
        int newGood = isLikedList[index] ? currentGood + 1 : currentGood - 1;

        transaction.update(docRef, {'good': newGood});
      });
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

  void _seekTo(double seconds) {
    final controller = _controllers[_currentIndex];
    controller.seekTo(Duration(seconds: seconds.toInt()));
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
                final controller = _controllers[index];

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
                                    child: CircularProgressIndicator()),
                          ),
                          Expanded(
                            flex: 2,
                            child: ImageSlider(imageUrls: imageSlides[index]),
                          ),
                        ],
                      ),
                      RightSideButtons(
                        onLikePressed: () =>
                            _toggleLike(docIds[index], index), // ✅ docId を渡す
                        isLiked: isLikedList[index],
                        likeCount: likeCountList[index],
                        shereUrl: shareUrls[index],
                        docId: docIds[index], // ✅ ここで docId を渡す
                      ),
                      Positioned(
                        bottom: 0,
                        left: 16,
                        right: 16,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 0.0),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 0.0),
                          ),
                          child: Slider(
                            activeColor: Colors.pink[200],
                            inactiveColor: Colors.pink[50],
                            min: 0,
                            max: controller.value.duration.inSeconds.toDouble(),
                            value:
                                controller.value.position.inSeconds.toDouble(),
                            onChanged: (value) {
                              _seekTo(value);
                            },
                          ),
                        ),
                      ),
                      if (!_controllers[index].value.isPlaying)
                        Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 80,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
