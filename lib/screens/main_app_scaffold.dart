import 'package:flutter/material.dart';
import 'dashboard_content.dart';
import 'route_planner_screen.dart';
import 'news_content.dart'; 
import '../widgets/app_drawer.dart';

class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({super.key});

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screenContents = const [
    DashboardContent(),
    RoutePlannerScreen(),
    NewsContent(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. KATMAN: Arkaplan Resmi
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            errorBuilder: (c, e, s) =>
                Container(color: const Color(0xFF121212)),
          ),
        ),

        // 2. KATMAN: Karartma Perdesi
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.35),
          ),
        ),

        // 3. KATMAN: Uygulama İskeleti
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: const Text(
              'Erzurum Atlası',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: _screenContents[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white60,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Ana Sayfa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.psychology),
                  label: 'AI Rota',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.article),
                  label: 'Haberler',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}