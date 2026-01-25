import 'package:cloud_firestore/cloud_firestore.dart';

// --- UniversityModel ---
class UniversityModel {
  final String id;
  final String name;
  final String description;
  final String addressDetail;
  final String imageUrl;
  final double rating;

  UniversityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.addressDetail,
    required this.imageUrl,
    required this.rating,
  });

  factory UniversityModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return UniversityModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      addressDetail: data['address_detail'] ?? '',
      imageUrl: data['image_url'] ?? '',
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0,
    );
  }
}

// --- CampusMapModel ---
class CampusMapModel {
  final String id;
  final String title;
  final String imageUrl;
  final String universityId;

  CampusMapModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.universityId,
  });

  factory CampusMapModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return CampusMapModel(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['image_url'] ?? '',
      universityId: data['university_id'] ?? '',
    );
  }
}

// --- GÜNCELLENEN KISIM: FacultyModel ---
class FacultyModel {
  final String id;
  final String name;
  final String description;
  final String addressDetail;
  final String imageUrl;
  final String category;
  // ✅ YENİ: Bölümleri liste olarak tutuyoruz
  final List<String> departments; 

  FacultyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.addressDetail,
    required this.imageUrl,
    required this.category,
    required this.departments,
  });

  factory FacultyModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    
    return FacultyModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      addressDetail: data['address_detail'] ?? '',
      imageUrl: data['image_url'] ?? '',
      category: data['category'] ?? '',
      // ✅ YENİ: Veritabanındaki array'i List<String>'e çeviriyoruz
      departments: List<String>.from(data['departments'] ?? []), 
    );
  }
}

// DepartmentModel'e artık gerek kalmadı çünkü veriyi string listesi olarak alıyoruz.
// Ama istersen silmeyebilirsin, zararı yok.
class DepartmentModel {
  final String id;
  final String name;
  final String facultyId;

  DepartmentModel({required this.id, required this.name, required this.facultyId});

  factory DepartmentModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return DepartmentModel(
      id: doc.id,
      name: data['name'] ?? '',
      facultyId: data['faculty_id'] ?? '',
    );
  }
}