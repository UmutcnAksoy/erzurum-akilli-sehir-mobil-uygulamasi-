import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CityGuideDetailScreen extends StatelessWidget {
  final String name;
  final String description;
  final String address;
  final String category;
  final String imageUrl;
  final String rating;
  final String visitDuration;
  final double? latitude;
  final double? longitude;

  const CityGuideDetailScreen({
    super.key,
    required this.name,
    required this.description,
    required this.address,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.visitDuration,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÜST RESİM
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    imageUrl.isNotEmpty
                        ? imageUrl
                        : 'https://placehold.co/600x300/333/fff?text=$name',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                ),
              ),
            ),

            // KART İÇERİĞİ
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Açıklama",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    Text(
                      description,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 30),

                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: [
                        _buildDetailChip(LucideIcons.mapPin, "Erzurum"),
                        _buildDetailChip(LucideIcons.clock, '$visitDuration dk'),
                        _buildDetailChip(LucideIcons.star, rating, Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "Adres Detayları",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    Text(
                      address.isNotEmpty
                          ? address
                          : 'Adres bilgisi mevcut değil.',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text,
      [Color iconColor = Colors.white70]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}