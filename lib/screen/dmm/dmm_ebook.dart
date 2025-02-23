import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample_reels/component/side_buttons.dart';
import 'package:preload_page_view/preload_page_view.dart';

/// DMMの電子書籍ページを表示するウィジェット
class DmmEbookPage extends StatefulWidget {
  const DmmEbookPage({Key? key}) : super(key: key);

  @override
  State<DmmEbookPage> createState() => DmmEbookPageState();
}

class DmmEbookPageState extends State<DmmEbookPage> {
  // いいねフラグ（trueならいいねが押されている状態）
  bool _isLiked = false;
  // いいね数
  int _likeCount = 0;

  // 縦方向のページコントローラ
  // 1作品につき1ページとして扱い、作品同士を縦スクロールで切り替える
  final PageController _verticalPageController = PageController();

  // 現在表示している作品のインデックス
  int _currentIndex = 0;

  // 現在表示している作品内のページ番号（横スクロールでのページ）
  int _currentPage = 0;

  // Firestoreから取得した作品ごとの画像URLリストを格納
  // 例: [[imgA_1.jpg, imgA_2.jpg], [imgB_1.jpg, imgB_2.jpg], ...]
  List<List<String>> _mangaUrls = [];

  @override
  void initState() {
    super.initState();
    // ウィジェット生成時にFirestoreから画像を取得
    _fetchImagesFromFirestore();
  }

  /// Firestoreから作品のサンプル画像URLを取得し、_mangaUrlsへ格納する
  Future<void> _fetchImagesFromFirestore() async {
    try {
      // 'Products'コレクションからdoc('m9BJjrgbEY3UW6sARIXF')を指定し、
      // その下の 'DmmEbook' コレクションを取得
      final snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .doc('m9BJjrgbEY3UW6sARIXF')
          .collection('DmmEbook')
          .get();

      // 取得したデータを一時的に格納するリスト
      final newMangaUrls = <List<String>>[];

      // 各ドキュメントをループして「サンプル画像」フィールドを取得
      for (var doc in snapshot.docs) {
        // 「サンプル画像」フィールドが存在するかをチェック
        if (!doc.data().containsKey('サンプル画像')) {
          print("⚠️ 必要なフィールドが見つかりません: ${doc.data().keys}");
          continue;
        }

        // 「サンプル画像」をList<String>として取り出す
        final List<String> images = List<String>.from(doc['サンプル画像']);
        // 作品ごとに画像リストをnewMangaUrlsへ追加
        newMangaUrls.add(images);
      }

      // setStateで状態を更新（画面再描画）
      setState(() {
        _mangaUrls = newMangaUrls;
      });
    } catch (e) {
      print("エラーが発生しました: $e");
    }
  }

  /// いいねボタンが押された時に呼ばれるメソッド
  void _toggleLike() {
    setState(() {
      // いいね状態を反転し、like数を＋1 or -1 する
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _mangaUrls が空、あるいはFirestoreの取得がまだ完了していない場合の処理
    if (_mangaUrls.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(), // ローディングインジケータを表示
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        // 縦スクロールのPageView
        controller: _verticalPageController,
        scrollDirection: Axis.vertical,
        itemCount: _mangaUrls.length, // 作品数を指定
        onPageChanged: (index) {
          // 縦スクロールで別の作品に切り替わった際の処理
          setState(() {
            _currentIndex = index;
            _currentPage = 0; // 横スクロールページもリセット
          });
        },
        itemBuilder: (context, index) {
          // 作品を描画するウィジェット
          return Stack(
            children: [
              // ----------------------
              // 作品内ページの横スクロール
              // ----------------------
              PreloadPageView.builder(
                // 画像を事前読み込みするパラメータ
                preloadPagesCount: 2,
                scrollDirection: Axis.horizontal,
                itemCount: _mangaUrls[index].length, // 1つの作品のページ数
                onPageChanged: (pageIndex) {
                  setState(() {
                    _currentPage = pageIndex;
                  });
                },
                itemBuilder: (context, pageIndex) {
                  // 横スクロールの1ページ
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      // 枠丸めをしたImageウィジェットで表示
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          _mangaUrls[index][pageIndex],
                          fit: BoxFit.contain, // 画像を等比スケールで収める
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.8,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ----------------------
              // 画面下部中央にページ番号を表示
              // ----------------------
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
                      // 現在ページ / 全ページ
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

              // ----------------------
              // 画面右下にいいねボタンなどを表示
              // （SideButtonsは独自のコンポーネント）
              // ----------------------
              RightSideButtons(
                onLikePressed: _toggleLike, // いいねボタン押下時の処理
                isLiked: _isLiked,         // いいね状態
                likeCount: _likeCount,     // いいね数
              ),
            ],
          );
        },
      ),
    );
  }
}
