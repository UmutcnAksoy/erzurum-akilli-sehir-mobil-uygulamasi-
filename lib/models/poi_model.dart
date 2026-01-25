import 'package:cloud_firestore/cloud_firestore.dart';

// POI (Point of Interest) - Gezilecek Yerler Modeli
class POIModel {
  final String id;
  final String ad;            // Firebase: 'name'
  final String aciklama;      // Firebase: 'description'
  final String ilce;          // Firebase: 'district' veya 'address'
  final String kategori;      // Firebase: 'category' veya 'type'
  final String resimUrlsi;    // Firebase: 'image_url'
  final int ortalamaSure;     // Firebase: 'visit_duration' veya 'duration'
  final double puanOrtalamasi;// Firebase: 'rating'
  final int yorumSayisi;      // Firebase: 'review_count'
  final String adres;         // Firebase: 'address_detail' veya 'address'

  POIModel({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.ilce,
    required this.kategori,
    required this.resimUrlsi,
    required this.ortalamaSure,
    required this.puanOrtalamasi,
    required this.yorumSayisi,
    required this.adres,
  });

  // Firestore DocumentSnapshot'tan POIModel objesi oluşturan Factory metodu
  factory POIModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // --- GÜVENLİ SAYI DÖNÜŞTÜRÜCÜLER (Hata Önleyici) ---
    // Veritabanından sayı bazen String ("4.5"), bazen Int (4) gelebilir. Hepsini yönetir.
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return POIModel(
      id: doc.id,
      
      // 1. AD (NAME)
      ad: data['name'] ?? 'İsimsiz Mekan', 

      // 2. AÇIKLAMA (DESCRIPTION)
      // Açıklama yoksa kategori veya adres bilgisini göstererek boş kalmasını engelleriz.
      aciklama: data['description'] ?? '${data['category'] ?? ""} - ${data['address'] ?? "Açıklama girilmemiş."}',

      // 3. İLÇE (DISTRICT / ADDRESS)
      // 'district' alanı yoksa, 'address' alanını kullanır.
      ilce: data['district'] ?? data['address'] ?? 'Merkez', 

      // 4. KATEGORİ (CATEGORY / TYPE)
      kategori: data['category'] ?? data['type'] ?? 'Genel',

      // 5. RESİM (IMAGE_URL)
      resimUrlsi: data['image_url'] ?? '',

      // 6. ADRES DETAYI (ADDRESS_DETAIL / ADDRESS)
      adres: data['address_detail'] ?? data['address'] ?? 'Adres bilgisi yok.', 

      // 7. SAYISAL DEĞERLER (RATING, DURATION, REVIEW)
      ortalamaSure: parseInt(data['visit_duration'] ?? data['duration'] ?? 45),
      puanOrtalamasi: parseDouble(data['rating']),
      yorumSayisi: parseInt(data['review_count'] ?? 10), 
    );
  }

  @override
  String toString() {
    return 'POIModel(Ad: $ad, Kategori: $kategori, Puan: $puanOrtalamasi)';
  }
}