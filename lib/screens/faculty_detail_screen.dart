import 'package:flutter/material.dart';
import '../models/university_model.dart'; 

class FacultyDetailScreen extends StatelessWidget {
  final FacultyModel faculty; 

  const FacultyDetailScreen({super.key, required this.faculty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Yakutiye Tasarımı: Siyah Arkaplan
      body: CustomScrollView(
        slivers: [
          // --- 1. RESİM VE BAŞLIK ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                faculty.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    faculty.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 2. BİLGİ KISMI ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori
                  if (faculty.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                      ),
                      child: Text(
                        faculty.category.toUpperCase(),
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Açıklama
                  const Text("Açıklama", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    faculty.description.isNotEmpty ? faculty.description : "Açıklama bulunmuyor.",
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 25),

                  // Adres
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Adres Detayları", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(faculty.addressDetail, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bölümler Başlığı
                  const Text("Bölümler", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // --- 3. BÖLÜM LİSTESİ (DIRECT LİSTE) ---
          // Burada StreamBuilder YOK. Doğrudan listeyi basıyoruz.
          if (faculty.departments.isEmpty)
             SliverToBoxAdapter(
               child: Container(
                 margin: const EdgeInsets.symmetric(horizontal: 16),
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(12)),
                 child: const Center(
                   child: Text("Bu birimde kayıtlı bölüm yok.", style: TextStyle(color: Colors.grey)),
                 ),
               ),
             )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final deptName = faculty.departments[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: const Icon(Icons.school, color: Colors.blueAccent),
                      title: Text(deptName, style: const TextStyle(color: Colors.white)),
                    ),
                  );
                },
                childCount: faculty.departments.length,
              ),
            ),
            
          const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
        ],
      ),
    );
  }
}