import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/poi_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'poi_detail_screen.dart'; // POI Detay ekranını import ediyoruz

// Bu ekran, Kültürel ve Tarihi mekanları gösterecek şekilde tasarlanmıştır.

class POIListTestScreen extends StatefulWidget {
  const POIListTestScreen({super.key});

  @override
  State<POIListTestScreen> createState() => _POIListTestScreenState();
}

class _POIListTestScreenState extends State<POIListTestScreen> {
  // Arama ve filtreleme için state değişkenleri
  String _searchQuery = '';
  // Not: İlçe filtresi arayüzden kaldırıldı ama mantığı kodda tutuyoruz.
  String _selectedIlce = 'Tümü'; 
  final List<String> ilceOptions = ['Tümü', 'Yakutiye', 'Palandöken']; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // KRİTİK: Arka planı şeffaf yapıyoruz ki, ana iskeletteki gradient/resim görünsün.
      backgroundColor: Colors.transparent, 
      extendBodyBehindAppBar: true, 

      appBar: AppBar(
        title: const Text("Kültür & Tarihi Mekanlar"),
        // AppBar'ı şeffaf yapıyoruz
        backgroundColor: Colors.transparent,
        elevation: 0, 
        // Filtreleme ikonu kaldırıldı.
        actions: const [], 
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            // AppBar'ın altından başlasın diye üst padding veriyoruz
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
                fillColor: Colors.black.withOpacity(0.5), // Koyu şeffaf arka plan
              ),
            ),
          ),
          
          // Veri Akışını Dinleyen Ana Liste Alanı
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // KRİTİK DÜZELTME: Doğru alt koleksiyondan ('culture') çekiyoruz.
              stream: FirebaseFirestore.instance.collection('culture').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // Hata durumunda konsola yazdırıyoruz.
                  print('Firebase Veri Çekme Hatası: ${snapshot.error}');
                  return Center(child: Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                // Veri modeline dönüştürme
                final List<POIModel> pois = snapshot.data!.docs
                    .map((doc) => POIModel.fromFirestore(doc))
                    .toList();

                // Arama ve İlçe Filtrelemesi Uygulanması (Dart tarafında yapılıyor.)
                final filteredPois = pois.where((poi) {
                  final matchesSearch = poi.ad.toLowerCase().contains(_searchQuery);
                  // NOT: İlçe filtresi arayüzden kalktı ama mantık hala çalışır durumda.
                  final matchesIlce = _selectedIlce == 'Tümü' || poi.ilce == _selectedIlce; 
                  return matchesSearch && matchesIlce;
                }).toList();

                if (filteredPois.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aradığınız kritere uygun mekan bulunamadı.',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  );
                }

                // Listeyi görüntüleme
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredPois.length,
                  itemBuilder: (context, index) {
                    final poi = filteredPois[index];
                    // Kartın kendisi tıklanabilir hale getirildi
                    return GestureDetector(
                      onTap: () {
                        // Detay sayfasına navigasyon
                        Navigator.push(
                          context,
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
    );
  }
}

// NOT: İlçe Filtreleme Dropdown Widget'ı (Kaldırıldı)

// Tek bir POI (Point of Interest) için estetik kart tasarımı
class _PoiCard extends StatelessWidget {
  final POIModel poi;
  const _PoiCard({required this.poi});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15.0),
      // Kart rengini koyu şeffaf yaptık, Dashboard kartlarına uygun
      color: Colors.black.withOpacity(0.5), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim/Görsel Alanı
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                poi.resimUrlsi.isNotEmpty 
                    ? poi.resimUrlsi 
                    : 'https://placehold.co/100x100/333/fff?text=POI', // Placeholder URL
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.blueGrey.withOpacity(0.7),
                  child: const Center(
                    child: Icon(LucideIcons.imageOff, color: Colors.white54)
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15.0),

            // Metin ve Detay Alanı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.ad,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        poi.ilce,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const Spacer(),
                      const Icon(LucideIcons.clock, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        '${poi.ortalamaSure} dk',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    poi.aciklama,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  // Puan ve Yorumlar
                  Row(
                    children: [
                      const Icon(LucideIcons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        poi.puanOrtalamasi.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${poi.yorumSayisi} yorum)',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
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