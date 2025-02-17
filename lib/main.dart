import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 各スクリーンのimport
import 'package:sample_reels/screen/manga.dart';
import 'package:sample_reels/screen/movie.dart';
import 'package:sample_reels/screen/voice.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SampleReels',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const TopPage(title: 'Flutter Demo Home Page'),
    );
  }
}

// Riverpodの状態管理プロバイダー
final alignmentProvider = StateProvider<double>((ref) => -1);

class TopPage extends ConsumerStatefulWidget {
  const TopPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<TopPage> createState() => TopPageState();
}

class TopPageState extends ConsumerState<TopPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // タブボタン（動画・マンガ・ボイス）
            Row(
              children: [
                Expanded(
                    child: Container(
                        alignment: Alignment.center, child: Text("漫画"))),
                Expanded(
                    child: Container(
                        alignment: Alignment.center, child: Text("動画"))),
                Expanded(
                    child: Container(
                        alignment: Alignment.center, child: Text("ボイス"))),
              ],
            ),
            // タブの下線（スワイプに応じて動く）
            AnimatedAlign(
              alignment: Alignment(ref.watch(alignmentProvider), 0),
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black,
                height: 3.0,
                width: MediaQuery.of(context).size.width / 3,
              ),
            ),
            // スワイプ可能なページ
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(
                  enableInfiniteScroll: false,
                  viewportFraction: 1,
                  height: MediaQuery.of(context).size.height - 100,
                  onPageChanged: (index, reason) {
                    double result = (index - 1).toDouble();
                    ref.read(alignmentProvider.notifier).state = result;
                  },
                ),
                items: const [
                  MangaPage(),
                  MoviePage(),
                  VoicePage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
