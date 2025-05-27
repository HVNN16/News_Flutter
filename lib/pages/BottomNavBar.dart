import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.article),
          label: "Tin tức",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle),
          label: "Media",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: "Khám phá",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Thiết lập",
        ),
      ],
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    );
  }
}