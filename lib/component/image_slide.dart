import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;

  const ImageSlider({super.key, required this.imageUrls});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 300, // スライドの高さ
        autoPlay: true, // 自動スライド
        autoPlayInterval: Duration(seconds: 3), // 3秒ごとにスライド
        enlargeCenterPage: true, // 中央の画像を拡大
        viewportFraction: 0.8, // 画像の表示幅
      ),
      items: widget.imageUrls.map((imageUrl) {
        // ✅ `widget.imageUrls` に修正
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        );
      }).toList(),
    );
  }
}
