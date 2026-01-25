import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/university_model.dart'; 
// Eğer FacultyModel veya CampusMapModel farklı dosyalardaysa onları da import etmen gerekebilir.
// Örn: import '../models/campus_map_model.dart';

class UniversityDetailScreen extends StatefulWidget {
  static const routeName = '/university-detail';
  final String universityId; // Main.dart'tan gelen ID'yi alıyoruz

  const UniversityDetailScreen({Key? key, required this.universityId}) : super(key: key);

  @override
  _UniversityDetailScreenState createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen> {

  // Üniversite detaylarını ID'ye göre çeken fonksiyon
  Future<UniversityModel?> fetchUniversityDetails(String uniId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('universities')
          .doc(uniId)
          .get();

      if (doc.exists) {
        // UniversityModel'in içinde fromSnapshot olduğunu varsayıyoruz
        return UniversityModel.fromSnapshot(doc); 
      }
    } catch (e) {
      print("Üniversite detayı çekme hatası: $e");
    }
    return null;
  }

  // Kampüs haritasını çeken fonksiyon
  Future<CampusMapModel?> fetchCampusMap(String uniId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('campus_maps')
          .where('university_id', isEqualTo: uniId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return CampusMapModel.fromSnapshot(snapshot.docs.first);
      }
    } catch (e) {
      print("Harita hatası: $e");
    }
    return null;
  }

  // Tüm birimleri (Places) çeken Stream
  Stream<List<FacultyModel>> fetchAllPlaces(String uniId) {
    return FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('places')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FacultyModel.fromSnapshot(doc))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    // Önce Üniversite Bilgisini Çekiyoruz
    return FutureBuilder<UniversityModel?>(
      future: fetchUniversityDetails(widget.universityId),
      builder: (context, uniSnapshot) {
        
        // 1. Yükleniyor ekranı
        if (uniSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        // 2. Hata veya Veri Yok ekranı
        if (!uniSnapshot.hasData || uniSnapshot.data == null) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
            body: const Center(child: Text("Üniversite bulunamadı.", style: TextStyle(color: Colors.white))),
          );
        }

        // 3. Veri geldi, arayüzü çizelim
        final university = uniSnapshot.data!;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(university.name, style: const TextStyle(color: Colors.white)),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. KAMPÜS PLANI ---
                FutureBuilder<CampusMapModel?>(
                  future: fetchCampusMap(university.id), // widget.universityId yerine university.id kullanabiliriz
                  builder: (context, mapSnapshot) {
                    if (mapSnapshot.connectionState == ConnectionState.waiting) {
                      return Container(height: 250, color: Colors.grey[900]);
                    }
                    if (mapSnapshot.hasData) {
                       return SizedBox(
                         height: 250, width: double.infinity,
                         child: Image.network(mapSnapshot.data!.imageUrl, fit: BoxFit.cover),
                       );
                    } 
                    // Harita yoksa boş alan yerine daha şık bir placeholder koyabilirsin
                    return Container(
                      height: 200, 
                      color: Colors.grey[850], 
                      child: const Center(child: Icon(Icons.map, color: Colors.white24, size: 50))
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 2. ÜNİVERSİTE BİLGİSİ ---
                      Text(university.name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 5),
                          Expanded(child: Text(university.addressDetail, style: const TextStyle(color: Colors.grey, fontSize: 14))),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text("Hakkında", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(university.description, style: const TextStyle(color: Colors.white70, height: 1.5)),
                      
                      const SizedBox(height: 30),
                      const Divider(color: Colors.grey),
                      
                      // --- 3. GRUPLANDIRILMIŞ LİSTELER ---
                      StreamBuilder<List<FacultyModel>>(
                        stream: fetchAllPlaces(university.id),
                        builder: (context, placeSnapshot) {
                          if (placeSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!placeSnapshot.hasData || placeSnapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Text("Henüz birim eklenmemiş.", style: TextStyle(color: Colors.grey)),
                            );
                          }

                          final allPlaces = placeSnapshot.data!;

                          // VERİYİ FİLTRELEME
                          final faculties = allPlaces.where((place) {
                            final cat = place.category.toLowerCase();
                            return cat.contains('fakülte') || cat.contains('faculty') || cat.contains('mühendislik');
                          }).toList();

                          final libraries = allPlaces.where((place) {
                            final cat = place.category.toLowerCase();
                            return cat.contains('kütüphane') || cat.contains('library');
                          }).toList();

                          final others = allPlaces.where((place) {
                            return !faculties.contains(place) && !libraries.contains(place);
                          }).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (faculties.isNotEmpty) ...[
                                _buildSectionHeader("Fakülteler"),
                                _buildPlaceList(faculties, isClickable: true),
                              ],
                              
                              if (libraries.isNotEmpty) ...[
                                _buildSectionHeader("Kütüphaneler"),
                                _buildPlaceList(libraries, isClickable: false),
                              ],

                              if (others.isNotEmpty) ...[
                                _buildSectionHeader("Diğer Birimler"),
                                _buildPlaceList(others, isClickable: false),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        title,
        style: const TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPlaceList(List<FacultyModel> places, {bool isClickable = false}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: places.length,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final place = places[index];
        
        Widget cardContent = Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (place.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    place.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c,o,s) => Container(height: 140, color: Colors.grey[800]),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      place.addressDetail.isNotEmpty ? place.addressDetail : place.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (isClickable) {
          return GestureDetector(
            onTap: () {
              // 'arguments: place' diyerek FacultyDetailScreen'e nesne gönderiyorsun.
              // O sayfanın da bu nesneyi kabul ettiğinden emin olmalısın.
              Navigator.pushNamed(
                context, 
                '/faculty_detail', 
                arguments: place 
              );
            },
            child: cardContent,
          );
        } else {
          return cardContent;
        }
      },
    );
  }
}