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
  List<bool> isLikedList = []; // 各漫画ごとの「いいね」状態
  List<int> likeCountList = []; // 各漫画ごとの「いいね」数
  List<List<String>> _mangaUrls = []; // Firestore から取得する漫画ページ画像
  List<String> shareUrls = [];
  List<String> docIds = []; // Firestore のドキュメントIDリスト

  final PageController _verticalPageController = PageController();
  int _currentIndex = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchImagesFromFirestore();
  }

  /// Firestore から「サンプル画像」と「good」フィールドを取得
  Future<void> _fetchImagesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .doc('5gPSzfeZFiedoFjMgj5d')
          .collection('FanzaBook')
          .get();

      final newMangaUrls = <List<String>>[];
      final newLikeCountList = <int>[];
      final newIsLikedList = <bool>[];
      final newDocIds = <String>[];
      final newShareUrls = <String>[];

      for (var doc in snapshot.docs) {
        if (!doc.data().containsKey('imageUrls')) continue;

        // 🔥 FirestoreのデータがStringかListかを判定
        List<String> images = [];
        var imageData = doc['imageUrls']['list'];

        if (imageData is List) {
          images = List<String>.from(imageData); // 正しくリストの場合
        } else if (imageData is String) {
          images = [imageData]; // 文字列の場合、リストに変換
        }

        String productPageUrl = doc['affiliateUrl'] ?? "";
        int goodCount = doc['good'] ?? 0;
        String docId = doc.id;

        newMangaUrls.add(images);
        newLikeCountList.add(goodCount);
        newIsLikedList.add(false); // 初期状態は false
        newDocIds.add(docId);
        newShareUrls.add(productPageUrl);
      }

      setState(() {
        _mangaUrls = newMangaUrls;
        likeCountList = newLikeCountList;
        isLikedList = newIsLikedList;
        docIds = newDocIds;
        shareUrls = newShareUrls;
      });
    } catch (e) {
      print("❌ Firestoreデータ取得エラー: $e");
    }
  }

  /// Firestore の `good` を更新
  void _toggleLike(String docId, int index) async {
    setState(() {
      isLikedList[index] = !isLikedList[index];
      likeCountList[index] += isLikedList[index] ? 1 : -1;
    });

    try {
      var docRef = FirebaseFirestore.instance
          .collection('Products')
          .doc('5gPSzfeZFiedoFjMgj5d')
          .collection('FanzaBook')
          .doc(docId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        int currentGood = snapshot['good'] ?? 0;
        int newGood = isLikedList[index] ? currentGood + 1 : currentGood - 1;

        transaction.update(docRef, {'good': newGood});
      });

      // Firestore にユーザーのいいね状態を保存
      String userId = "test_user"; // TODO: 実際のユーザーIDを設定
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('LikedManga')
          .doc(docId)
          .set({'liked': isLikedList[index]});
    } catch (e) {
      print("❌ Firestore `good` 更新エラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mangaUrls.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _verticalPageController,
        scrollDirection: Axis.vertical,
        itemCount: _mangaUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _currentPage = 0;
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
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
                          fit: BoxFit.contain,
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.8,
                        ),
                      ),
                    ),
                  );
                },
              ),
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
              RightSideButtons(
                onLikePressed: () =>
                    _toggleLike(docIds[index], index), // ✅ docId を渡す
                isLiked: isLikedList[index], // ✅ 各漫画の状態を参照
                likeCount: likeCountList[index], // ✅ 各漫画の like 数を参照
                shereUrl: shareUrls[index],
                docId: docIds[index], // ✅ docId を渡す
              ),
            ],
          );
        },
      ),
    );
  }
}
