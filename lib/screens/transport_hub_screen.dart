import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'bus_lines_screen.dart';
import 'bus_stops_screen.dart';

class TransportHubScreen extends StatelessWidget {
  const TransportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Toplu Taşıma",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ulaşım Rehberi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Erzurum içi otobüs hatlarını ve duraklarını buradan inceleyebilirsin.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // 1. OTOBÜS HATLARI KARTI
            _buildHubCard(
              context,
              title: "Otobüs Hatları",
              subtitle: "Tüm güzergahlar ve hat detayları",
              icon: LucideIcons.navigation, 
              color: Colors.blueAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BusLinesScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            // 2. OTOBÜS DURAKLARI KARTI
            _buildHubCard(
              context,
              title: "Otobüs Durakları",
              subtitle: "Konumuna en yakın durakları bul",
              icon: LucideIcons.mapPin,
              color: Colors.redAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BusStopsScreen()),
                );
              },
            ),
            
            // Alt kısımdaki boşluğu korumak için Spacer bıraktım ama içeriği sildim
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Hub Kartı Oluşturucu
  Widget _buildHubCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), Colors.black.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}