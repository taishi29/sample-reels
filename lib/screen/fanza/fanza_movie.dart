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
  bool _isLiked = false;
  int _likeCount = 0;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<String> videoUrls = [];
  List<List<String>> imageSlides = [];
  List<VideoPlayerController> _controllers = [];
  bool _isMuted = false;
  bool _showControls = false;
  double _opacity = 0.0; // ✅ フェードアウト用の透明度

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

        // **リスナーを追加して、シークバーをリアルタイム更新**
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

                      // **シークバー（つまみなし）**
                      Positioned(
                        bottom: 0,
                        left: 16,
                        right: 16,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 0.0), // ✅ つまみを消す
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 0.0), // ✅ つまみの影も消す
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

                      // **再生/停止ボタン（動画が停止中のみ表示）**
                      if (!_controllers[index].value.isPlaying)
                        Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 80,
                            color: Colors.white.withOpacity(0.7), // ✅ 半透明にする
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
