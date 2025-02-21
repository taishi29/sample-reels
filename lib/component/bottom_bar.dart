import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onItemTapped; // 親Widgetに選択イベントを通知
  final int currentIndex; // 選択中のタブを親から受け取る

  const BottomNavBar({
    Key? key,
    required this.onItemTapped,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black, // 背景を黒に
      currentIndex: widget.currentIndex, // 現在の選択中インデックス
      onTap: widget.onItemTapped, // タップ時の処理
      selectedItemColor: Colors.pink[100], // 選択されたアイテムの色
      unselectedItemColor: Colors.white70, // 非選択時のアイテムの色（少し薄めの白）
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.white), // アイコンを白色に
          label: 'DMM',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite, color: Colors.white),
          label: 'FANZA',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications, color: Colors.white),
          label: 'Setting',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Colors.white),
          label: 'MyAcount',
        ),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}
