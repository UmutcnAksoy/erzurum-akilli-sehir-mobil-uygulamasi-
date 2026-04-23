import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/bus_stop_model.dart';

class BusStopsScreen extends StatefulWidget {
  const BusStopsScreen({super.key});

  @override
  State<BusStopsScreen> createState() => _BusStopsScreenState();
}

class _BusStopsScreenState extends State<BusStopsScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Otobüs Durakları",
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Durak ismi ara...",
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bus_stops')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Hata: ${snapshot.error}",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Kayıtlı durak bulunamadı.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                var stops = snapshot.data!.docs
                    .map((doc) => BusStop.fromFirestore(doc))
                    .toList();

                if (searchQuery.isNotEmpty) {
                  stops = stops
                      .where((s) =>
                          s.name.toLowerCase().contains(searchQuery))
                      .toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: stops.length,
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    return _buildStopCard(stop);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard(BusStop stop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.mapPin,
              color: Colors.redAccent, size: 20),
        ),
        title: Text(
          stop.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: stop.description.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  stop.description,
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
      ),
    );
  }
}