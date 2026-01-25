import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/poi_model.dart';
import 'poi_detail_screen.dart';

class FoodPoiScreen extends StatefulWidget {
  const FoodPoiScreen({super.key});

  @override
  State<FoodPoiScreen> createState() => _FoodPoiScreenState();
}

class _FoodPoiScreenState extends State<FoodPoiScreen> {
  String _searchQuery = '';
  final String _selectedIlce = 'Tümü';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Kafe & Restoranlar", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.black), 
        child: Column(
          children: [
            // --- ARAMA ÇUBUĞU ---
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 16.0, right: 16.0, bottom: 16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Mekânlarda Ara...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(LucideIcons.search, color: Colors.white70),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // --- LİSTE ALANI ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // DİKKAT: Koleksiyon adı 'food_places' olarak düzeltildi!
                stream: FirebaseFirestore.instance
                    .collection('food_places') 
                    .snapshots(),
                builder: (context, snapshot) {
                  // 1. Hata Durumu
                  if (snapshot.hasError) {
                    return Center(child: Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }

                  // 2. Yükleniyor Durumu
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }

                  // 3. Veri Yok Durumu
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Henüz hiç mekan yok.\nFirebase "food_places" koleksiyonu boş görünüyor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  // Verileri Modele Çevirme
                  final List<POIModel> pois = snapshot.data!.docs
                      .map((doc) => POIModel.fromFirestore(doc))
                      .toList();

                  // Arama Filtreleme
                  final filteredPois = pois.where((poi) {
                    final matchesSearch = poi.ad.toLowerCase().contains(_searchQuery);
                    return matchesSearch;
                  }).toList();

                  // Filtre Sonucu Boşsa
                  if (filteredPois.isEmpty) {
                    return const Center(child: Text("Aradığınız kriterde mekan bulunamadı.", style: TextStyle(color: Colors.white54)));
                  }

                  // Listeyi Çizdirme
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: filteredPois.length,
                    itemBuilder: (context, index) {
                      final poi = filteredPois[index];
                      return GestureDetector(
                        onTap: () {
                           Navigator.of(context).push(
                             MaterialPageRoute(
                               builder: (context) => POIDetailScreen(poi: poi),
                             ),
                           );
                        },
                        child: _PoiCard(poi: poi),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Kart Tasarımı
class _PoiCard extends StatelessWidget {
  final POIModel poi;
  const _PoiCard({required this.poi});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15.0),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                poi.resimUrlsi.isNotEmpty 
                    ? poi.resimUrlsi 
                    : 'https://ui-avatars.com/api/?name=${poi.ad}&background=random',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(
                  width: 100, height: 100, color: Colors.grey[800], 
                  child: const Icon(LucideIcons.imageOff, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 15.0),
            // Yazılar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.ad,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 14, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      // Modelde district yoksa address'i kullandığımız için burası dolu gelecek
                      Expanded(child: Text(poi.ilce, style: const TextStyle(color: Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(LucideIcons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(poi.puanOrtalamasi.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}