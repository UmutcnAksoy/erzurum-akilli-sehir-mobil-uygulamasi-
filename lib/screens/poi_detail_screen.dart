import 'package:flutter/material.dart';
import '../models/poi_model.dart'; 
import 'package:lucide_icons/lucide_icons.dart';

// Bu ekran, listeden seçilen tek bir POI'nin tüm detaylarını gösterir.
class POIDetailScreen extends StatelessWidget {
  // Seçilen POI'nin tüm verisini bu model üzerinden alıyoruz.
  final POIModel poi;
  
  const POIDetailScreen({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    // Scaffold'u transparan yapıyoruz ki, altındaki ana görsel/gradient görünsün.
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, 
      
      appBar: AppBar(
        title: Text(
          poi.ad,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // AppBar'ı şeffaf yapıyoruz
        elevation: 0,
      ),
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim Alanı (Üstte büyük resim)
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                // Resim URL'si boşsa Placeholder kullan
                image: DecorationImage(
                  image: NetworkImage(
                    poi.resimUrlsi.isNotEmpty 
                      ? poi.resimUrlsi 
                      : 'https://placehold.co/600x300/333/fff?text=${poi.ad}',
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
                    poi.ad,
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
            
            // Detay Kartı (Şeffaf arkaplan üzerinde)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7), // Koyu şeffaf kart
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Açıklama
                    const Text(
                      "Açıklama",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    Text(
                      poi.aciklama,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    // Kriterler: İlçe, Süre, Puan
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: [
                        _buildDetailChip(LucideIcons.mapPin, poi.ilce),
                        _buildDetailChip(LucideIcons.clock, '${poi.ortalamaSure} dk'),
                        _buildDetailChip(LucideIcons.star, poi.puanOrtalamasi.toStringAsFixed(1), Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // Adres ve Harita Butonu
                    const Text(
                      "Adres Detayları",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    Text(
                      poi.adres.isNotEmpty ? poi.adres : 'Adres bilgisi mevcut değil.',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // BURAYA HARİTA/NAVİGASYON API ENTEGRASYONU GELECEK
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Harita navigasyonu başlatılıyor...')),
                          );
                        },
                        icon: const Icon(LucideIcons.map),
                        label: const Text('Haritada Göster & Navigasyon Başlat'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xFF2C5364), // Temaya uygun vurgu rengi
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Yardımcı Widget: Kriterleri gösteren küçük çip
  Widget _buildDetailChip(IconData icon, String text, [Color iconColor = Colors.white70]) {
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
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}