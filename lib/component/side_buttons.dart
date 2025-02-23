import 'package:flutter/material.dart';
import 'package:sample_reels/component/comment.dart';

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
  // ✅ コメント入力用のモーダルを表示
  void _showCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ 全画面表示に近いスクロール可能なモーダル
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white, // ✅ 背景色
      builder: (context) => const CommentSheet(), // ✅ `CommentSheet` を呼び出す
    );
  }

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
                  color: widget.isLiked ? Colors.pinkAccent : Colors.white,
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

          // ✅ コメントボタン（押すとモーダルが開く）
          GestureDetector(
            onTap: () =>
                _showCommentSheet(context), // ✅ `showModalBottomSheet` を実行
            child: Column(
              children: [
                const Icon(Icons.comment, color: Colors.white, size: 40),
                const Text("コメント",
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
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
