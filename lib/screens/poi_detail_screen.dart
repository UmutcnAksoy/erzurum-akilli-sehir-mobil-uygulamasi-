import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/poi_model.dart';

class POIDetailScreen extends StatelessWidget {
  final POIModel poi;

  const POIDetailScreen({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                poi.ad,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  poi.resimUrlsi.isNotEmpty
                      ? Image.network(
                          poi.resimUrlsi,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[900],
                            child: const Icon(LucideIcons.imageOff,
                                color: Colors.white54, size: 50),
                          ),
                        )
                      : Container(
                          color: Colors.grey[900],
                          child: const Icon(LucideIcons.imageOff,
                              color: Colors.white54, size: 50),
                        ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ADRES BLOĞU
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(LucideIcons.mapPin,
                                color: Colors.redAccent, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Açık Adres",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          poi.adres,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // PUAN, SÜRE VE YORUM
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildInfoChip(LucideIcons.clock,
                          "${poi.ortalamaSure} dk", Colors.white70),
                      _buildInfoChip(Icons.star,
                          poi.puanOrtalamasi.toStringAsFixed(1), Colors.amber),
                      _buildInfoChip(LucideIcons.messagesSquare,
                          "${poi.yorumSayisi} Yorum", Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ],
      ),
    );
  }
}