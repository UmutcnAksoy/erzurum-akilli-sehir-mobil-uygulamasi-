import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/bus_line_model.dart';

class BusLineDetailScreen extends StatelessWidget {
  final BusLine line;

  const BusLineDetailScreen({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Erzurum Atlası koyu teması
      body: CustomScrollView(
        slivers: [
          // --- ÜST BAŞLIK VE HAT KODU ---
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "${line.code} Güzergahı",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blueAccent.withOpacity(0.4),
                      Colors.black,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.bus,
                    size: 80,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ),

          // --- HAT BİLGİ ÖZETİ ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                line.type,
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(LucideIcons.clock, color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            const Text(
                              "Aktif",
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          line.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          line.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Durak Listesi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // --- DURAK ÇİZELGESİ (TIMELINE) ---
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final stop = line.route[index];
                final bool isFirst = index == 0;
                final bool isLast = index == line.route.length - 1;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sol Timeline Çizgisi
                      Column(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: isFirst 
                                ? Colors.greenAccent 
                                : (isLast ? Colors.redAccent : Colors.blueAccent),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: (isFirst ? Colors.greenAccent : Colors.blueAccent).withOpacity(0.3),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 60,
                              color: Colors.white10,
                            ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      // Durak Bilgisi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatStopName(stop['stop_id'].toString()),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isFirst ? "Başlangıç Durağı" : (isLast ? "Varış Durağı" : "Ara Durak"),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: line.route.length,
            ),
          ),
          
          // Alt Boşluk
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  // Durak ID'lerini temizleyip güzel gösteren yardımcı fonksiyon
  String _formatStopName(String id) {
    return id
        .replaceAll('d_', '')
        .replaceAll('_', ' ')
        .toUpperCase();
  }
}