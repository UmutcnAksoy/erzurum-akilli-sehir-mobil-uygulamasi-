// lib/screens/news_content.dart (NİHAİ KOD - IMPORT DAHİL)

import 'package:flutter/material.dart'; // <--- DOĞRU IMPORT

class NewsContent extends StatelessWidget {
  const NewsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    final double bottomNavHeight = kBottomNavigationBarHeight;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: statusBarHeight + appBarHeight + 10,
        bottom: bottomNavHeight + 20,
        left: 16.0,
        right: 16.0,
      ),
      child: const Center(
        child: Text(
          "Haberler Modülü BURAYA GELECEK.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}