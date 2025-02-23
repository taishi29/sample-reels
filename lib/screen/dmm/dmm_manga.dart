import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample_reels/component/side_buttons.dart';
import 'package:preload_page_view/preload_page_view.dart';

/// DMMのマンガページを表示するStatefulWidget
class DmmMangaPage extends StatefulWidget {
  const DmmMangaPage({Key? key}) : super(key: key);

  @override
  State<DmmMangaPage> createState() => DmmMangaPageState();
}

/// DMMマンガページの状態を管理するクラス
class DmmMangaPageState extends State<DmmMangaPage> {
  /// いいねされているかどうかのフラグ（true = いいね中）
  bool _isLiked = false;

  /// いいねの総数
  int _likeCount = 0;

  /// 縦スクロールで複数の作品を切り替えるためのPageController
  final PageController _verticalPageController = PageController();

  /// 現在表示中の作品インデックス（縦スクロール）
  int _currentIndex = 0;

  /// 現在表示中の作品のページインデックス（横スクロール）
  int _currentPage = 0;

  /// Firestoreから取得したマンガの画像URLを格納するリスト
  /// 例: [[page1.jpg, page2.jpg, ...], [page1.jpg, page2.jpg, ...], ...]
  List<List<String>> _mangaUrls = [];

  @override
  void initState() {
    super.initState();
    // ウィジェット生成時にFirestoreからデータを読み込む
    _fetchImagesFromFirestore();
  }

  /// Firestoreから「サンプル画像」フィールドを取得し、_mangaUrlsへ格納
  Future<void> _fetchImagesFromFirestore() async {
    try {
      // 'Products'コレクション内の m9BJjrgbEY3UW6sARIXF ドキュメント配下にある
      // 'DmmManga'コレクションを取得
      final snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .doc('m9BJjrgbEY3UW6sARIXF')
          .collection('DmmManga')
          .get();

      // 取得結果を格納する一時リスト
      final newMangaUrls = <List<String>>[];

      // 各ドキュメントをループし、"サンプル画像" フィールドを取得
      for (var doc in snapshot.docs) {
        // "サンプル画像"フィールドがあるか確認
        if (!doc.data().containsKey('サンプル画像')) {
          print("⚠️ 必要なフィールドが見つかりません: ${doc.data().keys}");
          // フィールドがない場合はスキップ
          continue;
        }

        // "サンプル画像"をList<String>として取得
        final List<String> images = List<String>.from(doc['サンプル画像']);
        // マンガ1作品分のページURLリストを追加
        newMangaUrls.add(images);
      }

      // 取得したリストをセットして再描画
      setState(() {
        _mangaUrls = newMangaUrls;
      });
    } catch (e) {
      print("エラーが発生しました: $e");
    }
  }

  /// いいねボタン押下時に呼ばれるメソッド
  void _toggleLike() {
    setState(() {
      // いいねフラグを反転し、_likeCountを増減する
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Firestoreからのデータが空の場合 (ロード中やデータが無い場合) の処理
    if (_mangaUrls.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(), // ローディングインジケータ
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      // 縦スクロールで作品を切り替えるPageView
      body: PageView.builder(
        controller: _verticalPageController,
        scrollDirection: Axis.vertical, // 縦方向にスクロール
        itemCount: _mangaUrls.length,    // 作品数
        onPageChanged: (index) {
          // 縦スクロールで別作品に切り替わった時の処理
          setState(() {
            _currentIndex = index;
            _currentPage = 0; // 新しい作品に切り替わると横スクロールページもリセット
          });
        },
        itemBuilder: (context, index) {
          // 1作品を構成するレイアウト
          return Stack(
            children: [
              // 横スクロールで作品の各ページをめくる
              PreloadPageView.builder(
                preloadPagesCount: 2,
                scrollDirection: Axis.horizontal,
                itemCount: _mangaUrls[index].length, // 1作品あたりのページ数
                onPageChanged: (pageIndex) {
                  setState(() {
                    _currentPage = pageIndex;
                  });
                },
                itemBuilder: (context, pageIndex) {
                  // 作品の1ページを表示
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      // 画像に枠丸めを行う
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          _mangaUrls[index][pageIndex],
                          fit: BoxFit.contain, // 画像を等比で表示し、余白があれば残す
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.8,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 画面下部中央に現在ページ/全ページ数を表示
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

              // 画面右下にいいねボタンなどを表示（SideButtonsは独自ウィジェット）
              RightSideButtons(
                onLikePressed: _toggleLike, // いいねボタンタップ時の処理
                isLiked: _isLiked,         // 現在のいいね状態
                likeCount: _likeCount,     // いいね数
              ),
            ],
          );
        },
      ),
    );
  }
}
