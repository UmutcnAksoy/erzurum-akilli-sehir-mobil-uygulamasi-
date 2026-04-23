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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Kafe & Restoranlar",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 100, left: 16.0, right: 16.0, bottom: 16.0),
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
                prefixIcon:
                    const Icon(LucideIcons.search, color: Colors.white70),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('food_places')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Hata: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Colors.blueAccent));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Henüz hiç mekan yok.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                final List<POIModel> pois = snapshot.data!.docs
                    .map((doc) => POIModel.fromFirestore(doc))
                    .toList();

                final filteredPois = pois
                    .where((poi) =>
                        poi.ad.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredPois.isEmpty) {
                  return const Center(
                      child: Text("Aradığınız kriterde mekan bulunamadı.",
                          style: TextStyle(color: Colors.white54)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
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

class _PoiCard extends StatelessWidget {
  final POIModel poi;
  const _PoiCard({required this.poi});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resim
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: poi.resimUrlsi.isNotEmpty
                ? Image.network(
                    poi.resimUrlsi,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),

          // İçerik
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        poi.kategori,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          poi.puanOrtalamasi.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  poi.ad,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin,
                        color: Colors.white54, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        poi.ilce,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 24),
                Text(
                  poi.aciklama,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant, color: Colors.white24, size: 48),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              poi.ad,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}