import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample_reels/component/side_buttons.dart';
import 'package:preload_page_view/preload_page_view.dart';

/// DMMの写真集ページを表示するStatefulWidget
class DmmPhotoPage extends StatefulWidget {
  const DmmPhotoPage({Key? key}) : super(key: key);

  @override
  State<DmmPhotoPage> createState() => DmmPhotoPageState();
}

/// DMM写真ページの状態を管理するクラス
class DmmPhotoPageState extends State<DmmPhotoPage> {
  /// いいね状態（true = いいね押下中）
  bool _isLiked = false;

  /// いいね数
  int _likeCount = 0;

  /// 縦スクロールで作品（写真集）を切り替えるためのコントローラ
  final PageController _verticalPageController = PageController();

  /// 現在表示中の作品インデックス（縦スクロール）
  int _currentIndex = 0;

  /// 現在表示中の作品内のページインデックス（横スクロール）
  int _currentPage = 0;

  /// Firestoreから取得した写真集の画像URLを格納するリスト
  /// 例: [[photo1.jpg, photo2.jpg, ...], [photo1.jpg, photo2.jpg, ...], ...]
  List<List<String>> _photoUrls = [];

  @override
  void initState() {
    super.initState();
    // ウィジェット生成時にFirestoreからデータを読み込む
    _fetchImagesFromFirestore();
  }

  /// Firestoreから「サンプル画像」フィールドを取得し、_photoUrlsへ格納
  Future<void> _fetchImagesFromFirestore() async {
    try {
      // 'Products'コレクション内の m9BJjrgbEY3UW6sARIXF ドキュメント配下にある
      // 'DmmPhoto' コレクションを取得（プロジェクトに合わせて修正）
      final snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .doc('m9BJjrgbEY3UW6sARIXF')
          .collection('DmmPhoto')
          .get();

      // 取得結果を一時的に入れるリスト
      final newPhotoUrls = <List<String>>[];

      // 各ドキュメントをループし「サンプル画像」フィールドが存在するかチェック
      for (var doc in snapshot.docs) {
        if (!doc.data().containsKey('サンプル画像')) {
          print("⚠️ 必要なフィールドが見つかりません: ${doc.data().keys}");
          continue; // フィールドが無ければスキップ
        }

        // 「サンプル画像」をList<String>として取得
        final List<String> images = List<String>.from(doc['サンプル画像']);
        // 写真集1作品分のページURLリストを追加
        newPhotoUrls.add(images);
      }

      // 取得したリストを状態にセット → 再描画
      setState(() {
        _photoUrls = newPhotoUrls;
      });
    } catch (e) {
      print("エラーが発生しました: $e");
    }
  }

  /// いいねボタンが押された時の処理
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Firestoreからのデータがまだ無い（ロード中または空）場合
    if (_photoUrls.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(), // ローディングインジケータ
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      // 縦スクロールで作品（写真集）を切り替える
      body: PageView.builder(
        controller: _verticalPageController,
        scrollDirection: Axis.vertical,
        itemCount: _photoUrls.length, // 写真集の数
        onPageChanged: (index) {
          // 別の作品に切り替わったらページ番号をリセット
          setState(() {
            _currentIndex = index;
            _currentPage = 0;
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              // 横スクロールで1作品内のページをめくる
              PreloadPageView.builder(
                preloadPagesCount: 2,
                scrollDirection: Axis.horizontal,
                itemCount: _photoUrls[index].length, // 作品内のページ数
                onPageChanged: (pageIndex) {
                  setState(() {
                    _currentPage = pageIndex;
                  });
                },
                itemBuilder: (context, pageIndex) {
                  // 1ページ分の写真を表示
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          _photoUrls[index][pageIndex],
                          fit: BoxFit.contain, // 画像を余白込みで表示
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.8,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 画面下部中央に「現在のページ / 全ページ数」を表示
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
                      "${_currentPage + 1} / ${_photoUrls[_currentIndex].length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // 画面右下にいいねボタン等を表示 (SideButtonsは独自ウィジェット)
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
