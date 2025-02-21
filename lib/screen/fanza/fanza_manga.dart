import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample_reels/component/side_buttons.dart';
import 'package:preload_page_view/preload_page_view.dart';

class FanzaMangaPage extends StatefulWidget {
  const FanzaMangaPage({Key? key}) : super(key: key);

  @override
  State<FanzaMangaPage> createState() => FanzaMangaPageState();
}

class FanzaMangaPageState extends State<FanzaMangaPage> {
  bool _isLiked = false;
  int _likeCount = 0;

  // 縦スクロールのコントローラ
  final PageController _verticalPageController = PageController();

  // 現在の作品インデックス
  int _currentIndex = 0;

  // 現在の横スクロールページインデックス
  int _currentPage = 0;

  // Firestore から取得した漫画ごとの画像リストを格納する
  // 例: [[page1.jpg, page2.jpg, ...], [page1.jpg, page2.jpg, ...], ...]
  List<List<String>> _mangaUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchImagesFromFirestore(); // Firestore からデータを取得
  }

  /// Firestore から「サンプル画像」フィールドを取得して _mangaUrls に格納する
  Future<void> _fetchImagesFromFirestore() async {
    try {
      // Firestore から `Products/m9BJjrgbEY3UW6sARIXF/Fanzacomic` コレクションのデータを取得
      final snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .doc('m9BJjrgbEY3UW6sARIXF') // プロジェクトに応じて修正
          .collection('Fanzacomic')
          .get();

      final newMangaUrls = <List<String>>[];

      for (var doc in snapshot.docs) {
        // 「サンプル画像」フィールドが存在するかチェック
        if (!doc.data().containsKey('サンプル画像')) {
          print("⚠️ 必要なフィールドが見つかりません: ${doc.data().keys}");
          continue; // フィールドがなければスキップ
        }

        // Firestore から「サンプル画像」(List<String>) を取得
        List<String> images = List<String>.from(doc['サンプル画像']);
        // 作品ごとのリストとして追加
        newMangaUrls.add(images);
      }

      // setState で反映
      setState(() {
        _mangaUrls = newMangaUrls;
      });
    } catch (e) {
      print("エラーが発生しました: $e");
    }
  }

  /// いいねボタンの処理
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Firestore からの読み込みがまだ完了していない or データが空の場合の処理
    if (_mangaUrls.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(), // ローディング表示
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _verticalPageController,
        scrollDirection: Axis.vertical, // 縦スクロールで作品を切り替え
        itemCount: _mangaUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index; 
            _currentPage = 0; // 新しい作品に切り替わったら横スクロールページをリセット
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              // 横スクロールで漫画のページをめくる
              PreloadPageView.builder(
                preloadPagesCount: 2,
                scrollDirection: Axis.horizontal,
                itemCount: _mangaUrls[index].length,
                onPageChanged: (pageIndex) {
                  setState(() {
                    _currentPage = pageIndex;
                  });
                },
                itemBuilder: (context, pageIndex) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          _mangaUrls[index][pageIndex],
                          fit: BoxFit.contain, // 余白を残して表示
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.8,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 下部中央にページ番号を表示
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${_currentPage + 1} / ${_mangaUrls[_currentIndex].length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // いいねボタンなどを右下に配置 (SideButtons は独自ウィジェット)
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
