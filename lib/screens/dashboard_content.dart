import 'package:flutter/material.dart';
import '../widgets/weather_summary_card.dart';
import '../screens/maskot_screen.dart';

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
          Text(
            "Hos Geldin, Dadas!",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Bugün Erzurum'da seni neler bekliyor?",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),

          const WeatherSummaryCard(),

          const SizedBox(height: 40),

          Center(child: _buildAiAssistantIcon(context)),

          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildAiAssistantIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MaskotScreen()),
      ),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.cyanAccent.withOpacity(0.3),
                    Colors.blueAccent.withOpacity(0.15),
                  ],
                ),
                border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.5), width: 1.5),
              ),
              child: const Icon(
                Icons.record_voice_over_outlined,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "AI Sesli Rehber ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Gezilecek yerler hakkında merak edilenler ",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}