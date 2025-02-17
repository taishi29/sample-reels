import 'package:flutter/material.dart';

class RightSideButtons extends StatefulWidget {
  final VoidCallback onLikePressed;
  final bool isLiked;
  final int likeCount;

  const RightSideButtons({
    super.key,
    required this.onLikePressed,
    required this.isLiked,
    required this.likeCount,
  });

  @override
  State<RightSideButtons> createState() => RightSideButtonsState();
}

class RightSideButtonsState extends State<RightSideButtons> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 20,
      child: Column(
        children: [
          // いいねボタン
          GestureDetector(
            onTap: widget.onLikePressed,
            child: Column(
              children: [
                Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.isLiked ? Colors.red : Colors.white,
                  size: 40,
                ),
                Text(
                  '${widget.likeCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // コメントボタン
          Column(
            children: [
              Icon(Icons.comment, color: Colors.white, size: 40),
              Text("0", style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 20),

          // ブックマークボタン
          Column(
            children: [
              Icon(Icons.bookmark_border, color: Colors.white, size: 40),
              Text("0", style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 20),

          // 共有ボタン
          Column(
            children: [
              Icon(Icons.more_horiz, color: Colors.white, size: 40),
              Text("シェア", style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
