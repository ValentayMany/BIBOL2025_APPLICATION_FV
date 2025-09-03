import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: Color(0xFF07325D),
      buttonBackgroundColor: Color(0xFF07325D),
      height: 60,
      items: <Widget>[
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.bookmark_border, size: 30, color: Colors.white),
        Icon(Icons.photo_library, size: 30, color: Colors.white),
        Icon(Icons.favorite_border, size: 30, color: Colors.white),
        Icon(Icons.person_outline, size: 30, color: Colors.white),
      ],
      onTap: onTap,
      index: currentIndex,
    );
  }
}