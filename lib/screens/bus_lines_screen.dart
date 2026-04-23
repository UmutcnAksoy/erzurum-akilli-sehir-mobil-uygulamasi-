import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/bus_line_model.dart';
import 'bus_line_detail_screen.dart';

class BusLinesScreen extends StatefulWidget {
  const BusLinesScreen({super.key});

  @override
  State<BusLinesScreen> createState() => _BusLinesScreenState();
}

class _BusLinesScreenState extends State<BusLinesScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Koyu tema arkaplanı
      appBar: AppBar(
        title: const Text(
          "Otobüs Hatları ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // --- ARAMA ÇUBUĞU ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Hat kodu veya isim ara...",
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

          // --- FİREBASE LİSTESİ ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bus_lines').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Hata oluştu: ${snapshot.error}",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Herhangi bir otobüs hattı bulunamadı.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                // Verileri modele çeviriyoruz
                var lines = snapshot.data!.docs.map((doc) => BusLine.fromFirestore(doc)).toList();

                // Arama filtresi
                if (searchQuery.isNotEmpty) {
                  lines = lines.where((l) {
                    return l.code.toLowerCase().contains(searchQuery) || 
                           l.name.toLowerCase().contains(searchQuery);
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: lines.length,
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    return _buildLineCard(context, line);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hat kartı tasarımı
  Widget _buildLineCard(BuildContext context, BusLine line) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Koyu gri kart rengi
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        onTap: () {
          // Güzergah detay ekranına yönlendirme
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusLineDetailScreen(line: line),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              line.code,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          line.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "${line.type} • ${line.route.length} Durak",
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          color: Colors.white24,
          size: 20,
        ),
      ),
    );
  }
}