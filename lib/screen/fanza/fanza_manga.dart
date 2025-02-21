import 'package:flutter/material.dart';
import 'package:sample_reels/component/side_buttons.dart';
import 'package:preload_page_view/preload_page_view.dart';

class FanzaMangaPage extends StatefulWidget {
  const FanzaMangaPage({super.key});

  @override
  State<FanzaMangaPage> createState() => FanzaMangaPageState();
}

class FanzaMangaPageState extends State<FanzaMangaPage> {
  bool _isLiked = false;
  int _likeCount = 0;
  final PageController _verticalPageController = PageController(); // ✅ 縦スクロール管理
  int _currentIndex = 0; // ✅ 現在の作品インデックス
  int _currentPage = 0; // ✅ 現在のページ番号（横スクロール用）

  // ✅ 漫画ごとの画像リスト
  final List<List<String>> mangaUrls = [
    [
      'https://doujin-assets.dmm.co.jp/digital/comic/d_524736/d_524736jp-001.jpg',
      'https://doujin-assets.dmm.co.jp/digital/comic/d_524736/d_524736jp-002.jpg',
      'https://doujin-assets.dmm.co.jp/digital/comic/d_524736/d_524736jp-003.jpg',
      'https://doujin-assets.dmm.co.jp/digital/comic/d_524736/d_524736jp-004.jpg',
    ],
    [
      'https://ebook-assets.dmm.co.jp/digital/e-book/b915awnmg01130/b915awnmg01130pl.jpg',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _verticalPageController,
        scrollDirection: Axis.vertical, // ✅ 縦スクロールで作品切り替え
        itemCount: mangaUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index; // ✅ 現在の作品を更新
            _currentPage = 0; // ✅ 新しい作品に切り替わったらページ番号をリセット
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              // ✅ 横スクロールで漫画のページをめくる
              PreloadPageView.builder(
                preloadPagesCount: 2, // ✅ 2ページ先までプリロード
                scrollDirection: Axis.horizontal, // ✅ 横スクロール
                itemCount: mangaUrls[index].length,
                onPageChanged: (pageIndex) {
                  setState(() {
                    _currentPage = pageIndex; // ✅ ページ番号を更新
                  });
                },
                itemBuilder: (context, pageIndex) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15), // ✅ 角を丸くする
                        child: Image.network(
                          mangaUrls[index][pageIndex],
                          fit: BoxFit.contain, // ✅ 余白を残して表示
                          width: MediaQuery.of(context).size.width *
                              0.9, // ✅ 画面の90%の幅
                          height: MediaQuery.of(context).size.height *
                              0.8, // ✅ 画面の80%の高さ
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ✅ 下部中央にページ番号を表示
              Positioned(
                bottom: 20, // ✅ 画面下に配置
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5), // ✅ 半透明の背景
                      borderRadius: BorderRadius.circular(10), // ✅ 角を丸くする
                    ),
                    child: Text(
                      "${_currentPage + 1} / ${mangaUrls[_currentIndex].length}", // ✅ 現在のページ / 総ページ数
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // ✅ いいねボタンなどを右下に配置
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

  // ✅ いいねボタンの処理
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }
}
