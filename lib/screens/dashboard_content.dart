import 'dart:ui'; // ImageFilter için gerekli
import 'package:flutter/material.dart';
import '../widgets/weather_summary_card.dart'; 

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- BAŞLIK ---
          Text(
            "Hoş Geldin, Dadaş!", 
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w800, 
              color: Colors.white, 
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Bugün Erzurum'da seni neler bekliyor?",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 24),
          
          // --- HAVA DURUMU ---
          const WeatherSummaryCard(), 

          const SizedBox(height: 40),

          // --- AI REHBER SİMGESİ (MERKEZDE) ---
          Center(child: _buildAiAssistantIcon()),

          // Alt menü boşluğu
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  // AI ASİSTAN SİMGESİ
  Widget _buildAiAssistantIcon() {
    return Column(
      children: [
        Container(
          width: 100, // Biraz daha büyüttüm, artık odak noktası burası
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.cyanAccent.withOpacity(0.3),
                Colors.blueAccent.withOpacity(0.1),
              ],
            ),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.2),
                blurRadius: 25,
                spreadRadius: 5,
              )
            ],
          ),
          child: const Icon(Icons.record_voice_over_outlined, color: Colors.white, size: 42),
        ),
        const SizedBox(height: 16),
        const Text(
          "AI Rehberi Başlat",
          style: TextStyle(
            color: Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Konumuna göre tarihi anlatır",
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}