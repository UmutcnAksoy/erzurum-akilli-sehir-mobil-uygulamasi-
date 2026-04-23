import 'package:cloud_firestore/cloud_firestore.dart';

// Bu sınıf, Firebase 'bus_lines' koleksiyonundaki verileri temsil eder.
class BusLine {
  final String id;
  final String code;        // Örn: "A1"
  final String name;        // Örn: "HAVALİMANI"
  final String description; // Güzergah açıklaması
  final String type;        // Örn: "Belediye", "Özel Halk"
  final List<dynamic> route; // Durak listesi (sequence ve stop_id içerir)

  BusLine({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.type,
    required this.route,
  });

  // Firestore belgesini BusLine nesnesine dönüştüren fabrika metodu
  factory BusLine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BusLine(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? 'Bilinmeyen Hat',
      description: data['description'] ?? 'Güzergah bilgisi bulunmuyor.',
      type: data['type'] ?? 'Genel',
      route: data['route'] ?? [],
    );
  }
}