// lib/screens/main_app_scaffold.dart (NİHAİ KOD - BEYAZ ALT İKONLAR)

import 'package:flutter/material.dart';
import 'dashboard_content.dart'; 
import 'route_content.dart';     
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
    RouteContent(),
    NewsContent(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        
        // KATMAN 1: Arkaplan Görseli
        Positioned.fill(
          child: Opacity(
            opacity: 0.6, 
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover, 
            ),
          ),
        ),

        // KATMAN 2: Şeffaf Scaffold
        Scaffold(
          backgroundColor: Colors.transparent, 
          extendBodyBehindAppBar: true, 
          extendBody: true, 

          appBar: AppBar(
            title: const Text('Erzurum Akıllı Şehir'),
            centerTitle: true,
            leading: Builder( 
              builder: (context) {
                return IconButton(
                  // Bu ikon temadan (main.dart) SİYAH geliyor, bu doğru.
                  icon: const Icon(Icons.menu), 
                  onPressed: () {
                    Scaffold.of(context).openDrawer(); 
                  },
                );
              },
            ),
            actions: const [], 
          ),
          drawer: const AppDrawer(), 
          
          body: _screenContents[_selectedIndex],

          // ALT MENÜ RENKLERİ GÜNCELLENDİ
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.transparent, 
            elevation: 0, 
            
            // TEMAYI EZİYOR VE BEYAZ YAPIYORUZ:
            selectedItemColor: Colors.white, // <--- SEÇİLİ İKON BEYAZ
            unselectedItemColor: Colors.white70, // <--- DİĞER İKONLAR SOLUK BEYAZ
            
            items: const <BottomNavigationBarItem>[
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
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ],
    );
  }
}