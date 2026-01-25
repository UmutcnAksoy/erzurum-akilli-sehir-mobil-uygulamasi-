import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/poi_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'poi_detail_screen.dart'; // Detay sayfasına geçiş için

// Bu ekran, Eczane ve Hastaneleri gösterecek şekilde tasarlanmıştır.

class HealthPoiScreen extends StatefulWidget {
  const HealthPoiScreen({super.key});

  @override
  State<HealthPoiScreen> createState() => _HealthPoiScreenState();
}

class _HealthPoiScreenState extends State<HealthPoiScreen> {
  // Arama ve filtreleme için state değişkenleri
  String _searchQuery = '';
  String _selectedIlce = 'Tümü';
  final List<String> ilceOptions = ['Tümü', 'Yakutiye', 'Palandöken']; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // KRİTİK: Arka planı şeffaf yapıyoruz
      backgroundColor: Colors.transparent, 
      extendBodyBehindAppBar: true, 

      appBar: AppBar(
        title: const Text("Eczane & Hastane"),
        backgroundColor: Colors.transparent,
        elevation: 0, 
        actions: const [], 
      ),
      body: Column(
        children: [
          // Arama Çubuğu
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
                hintText: 'Eczane/Hastane Ara...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(LucideIcons.search, color: Colors.white70),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                filled: true,
                fillColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          
          // Veri Akışını Dinleyen Ana Liste Alanı
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // KRİTİK: KOLEKSİYON ADI 'health' OLARAK AYARLANDI.
              stream: FirebaseFirestore.instance.collection('health').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                final List<POIModel> pois = snapshot.data!.docs
                    .map((doc) => POIModel.fromFirestore(doc))
                    .toList();

                final filteredPois = pois.where((poi) {
                  final matchesSearch = poi.ad.toLowerCase().contains(_searchQuery);
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
    );
  }
}

// Alt widgetlar: POIListTestScreen dosyasından kopyalanmıştır.
// Tek bir POI (Point of Interest) için estetik kart tasarımı
class _PoiCard extends StatelessWidget {
  final POIModel poi;
  const _PoiCard({required this.poi});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15.0),
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
                    : 'https://placehold.co/100x100/333/fff?text=POI',
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
                      // Yorum sayısı
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

// Bu modülde kullanılmıyor ama kodun çalışması için var
class _IlceFilterDropdown extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const _IlceFilterDropdown({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.filter, color: Colors.white),
      onSelected: onChanged,
      itemBuilder: (BuildContext context) {
        return options.map((String value) {
          return PopupMenuItem<String>(
            value: value,
            child: Text(
              value, 
              style: TextStyle(
                color: selectedValue == value ? Theme.of(context).primaryColor : Colors.black,
                fontWeight: selectedValue == value ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList();
      },
      color: Colors.white.withOpacity(0.9),
    );
  }
}