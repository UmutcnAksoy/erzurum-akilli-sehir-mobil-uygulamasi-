import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'city_guide_detail_screen.dart';

class CulturePoiScreen extends StatefulWidget {
  const CulturePoiScreen({super.key});

  @override
  State<CulturePoiScreen> createState() => _CulturePoiScreenState();
}

class _CulturePoiScreenState extends State<CulturePoiScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Kültür & Tarihi Mekanlar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Mekânlarda Ara...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('city_guide')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Colors.blueAccent));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Hata oluştu:\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Mekan verisi bulunamadı.",
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  );
                }

                var docs = snapshot.data!.docs;

                if (searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>?;
                    if (data == null) return false;
                    var name = (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    String name = data['name']?.toString() ?? 'İsimsiz Mekan';
                    String description = data['description']?.toString() ?? 'Açıklama bulunamadı.';
                    String address = data['address']?.toString() ??
                        data['district']?.toString() ??
                        'Adres yok';
                    String category = data['category']?.toString() ??
                        data['type']?.toString() ??
                        'Genel';
                    String imageUrl = data['image_url']?.toString() ?? '';
                    String rating = data['rating']?.toString() ?? '-';
                    String visitDuration = data['visit_duration']?.toString() ?? '45';

                    double? latitude;
                    double? longitude;
                    if (data['location'] is GeoPoint) {
                      final geoPoint = data['location'] as GeoPoint;
                      latitude = geoPoint.latitude;
                      longitude = geoPoint.longitude;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CityGuideDetailScreen(
                              name: name,
                              description: description,
                              address: address,
                              category: category,
                              imageUrl: imageUrl,
                              rating: rating,
                              visitDuration: visitDuration,
                              latitude: latitude,
                              longitude: longitude,
                            ),
                          ),
                        );
                      },
                      child: _buildPlaceCard(
                        name: name,
                        description: description,
                        category: category,
                        address: address,
                        imageUrl: imageUrl,
                        rating: rating,
                      ),
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

  Widget _buildPlaceCard({
    required String name,
    required String description,
    required String category,
    required String address,
    required String imageUrl,
    required String rating,
  }) {
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImagePlaceholder(name),
                  )
                : _buildImagePlaceholder(name),
          ),
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
                        color: Colors.blueAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatCategory(category),
                        style: const TextStyle(
                          color: Colors.blueAccent,
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
                          rating,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  name,
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
                        address,
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
                  description,
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

  Widget _buildImagePlaceholder(String name) {
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
          const Icon(Icons.museum, color: Colors.white24, size: 48),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              name,
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

  String _formatCategory(String cat) {
    if (cat.toLowerCase() == 'tourist_spot') return 'Turistik Nokta';
    if (cat.toLowerCase() == 'historical_site') return 'Tarihi Mekan';
    if (cat.toLowerCase() == 'culture') return 'Kültür';
    return cat.toUpperCase();
  }
}