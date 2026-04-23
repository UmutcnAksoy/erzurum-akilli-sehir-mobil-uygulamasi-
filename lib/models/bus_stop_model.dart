import 'package:cloud_firestore/cloud_firestore.dart';

class BusStop {
  final String id;
  final String name;        // Durak Adı
  final String description; // Durak Açıklaması
  final GeoPoint? location; // Harita Koordinatı

  BusStop({
    required this.id,
    required this.name,
    required this.description,
    this.location,
  });

  // Firebase'den gelen veriyi modele dönüştüren yardımcı fonksiyon
  factory BusStop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return BusStop(
      id: doc.id,
      // Firebase'deki farklı isimlendirme ihtimallerine karşı (name/ad) kontrolü
      name: data['name'] ?? data['ad'] ?? 'Bilinmeyen Durak',
      description: data['description'] ?? data['aciklama'] ?? 'Açıklama mevcut değil.',
      location: data['location'] as GeoPoint?,
    );
  }
} 