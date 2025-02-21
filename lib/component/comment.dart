import 'package:flutter/material.dart';

class CommentSheet extends StatefulWidget {
  const CommentSheet({super.key});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final List<String> _comments = []; // ✅ コメントリスト
  final TextEditingController _commentController =
      TextEditingController(); // ✅ 入力用コントローラー

  void _showInputField(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ キーボードの高さに対応
      backgroundColor: Colors.transparent, // ✅ 背景透明
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // ✅ キーボードの高さ分余白を確保
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white, // ✅ 背景色
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(15)), // ✅ 上の角を丸くする
            ),
            child: Row(
              children: [
                // ✅ プロフィール画像
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://pbs.twimg.com/profile_images/1476938674612805637/Z9-fGmey_400x400.jpg'),
                  radius: 18,
                ),
                const SizedBox(width: 8), // 余白

                // ✅ 入力欄
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    autofocus: true, // ✅ 自動でキーボードを開く
                    decoration: InputDecoration(
                      hintText: "すてきなコメントを書く…",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // ✅ 送信ボタン
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      setState(() {
                        _comments.add(_commentController.text); // ✅ コメント追加
                        _commentController.clear(); // ✅ 入力欄をクリア
                      });
                      Navigator.pop(context); // ✅ 入力完了で閉じる
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // ✅ 画面の60%の高さに設定
      padding: const EdgeInsets.all(16), // ✅ 全体の余白を追加
      decoration: BoxDecoration(
        color: Colors.white, // ✅ 背景色
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)), // ✅ 角を丸くする
      ),
      child: Column(
        children: [
          // ✅ コメント件数の表示
          Center(
            child: Text(
              "${_comments.length}件のコメント",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10), // ✅ 余白
          const Divider(height: 1, color: Colors.grey), // ✅ 境界線

          const SizedBox(height: 10), // ✅ 余白

          // ✅ コメントリスト（スクロール可能）
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length, // ✅ コメントの数
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://pbs.twimg.com/profile_images/1476938674612805637/Z9-fGmey_400x400.jpg'),
                      radius: 20,
                    ),
                    title: Text(
                      _comments[index],
                      style: const TextStyle(color: Colors.black),
                    ),
                    subtitle: const Text(
                      "1分前",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    trailing:
                        const Icon(Icons.favorite_border, color: Colors.grey),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10), // ✅ 余白

          // ✅ コメント入力欄（タップするとキーボードの上にポップアップ）
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://pbs.twimg.com/profile_images/1476938674612805637/Z9-fGmey_400x400.jpg'),
                radius: 18,
              ),
              const SizedBox(width: 8), // ✅ 余白
              Expanded(
                child: GestureDetector(
                  onTap: () => _showInputField(context), // ✅ タップで入力欄を表示
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // ✅ 背景色を薄いグレーに
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      "すてきなコメントを書く…",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // ✅ 余白
        ],
      ),
    );
  }
}
