import 'package:cloud_firestore/cloud_firestore.dart';

class POIModel {
  final String id;
  final String ad;
  final String aciklama;
  final String ilce;
  final String kategori;
  final String resimUrlsi;
  final int ortalamaSure;
  final double puanOrtalamasi;
  final int yorumSayisi;
  final String adres;
  final double? latitude;
  final double? longitude;

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
    this.latitude,
    this.longitude,
  });

  factory POIModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

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

    double? lat;
    double? lng;
    if (data['location'] is GeoPoint) {
      final geoPoint = data['location'] as GeoPoint;
      lat = geoPoint.latitude;
      lng = geoPoint.longitude;
    }

    return POIModel(
      id: doc.id,
      ad: data['name'] ?? data['ad'] ?? 'İsimsiz Mekan',
      aciklama: data['description'] ?? data['aciklama'] ?? 'Açıklama girilmemiş.',
      ilce: data['district'] ?? data['ilce'] ?? data['address'] ?? 'Merkez',
      kategori: data['category'] ?? data['type'] ?? data['kategori'] ?? 'Genel',
      resimUrlsi: data['image_url'] ?? data['resim_url'] ?? data['resimUrlsi'] ?? '',
      adres: data['address'] ?? data['address_detail'] ?? data['adres'] ?? 'Adres bilgisi yok.',
      ortalamaSure: parseInt(data['visit_duration'] ?? data['duration'] ?? data['ortalamaSure'] ?? 45),
      puanOrtalamasi: parseDouble(data['rating'] ?? data['puanOrtalamasi'] ?? 0.0),
      yorumSayisi: parseInt(data['review_count'] ?? data['yorumSayisi'] ?? 0),
      latitude: lat,
      longitude: lng,
    );
  }
}