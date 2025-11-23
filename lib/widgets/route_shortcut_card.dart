// lib/screens/route_content.dart (NİHAİ FORM KODU)

import 'package:flutter/material.dart';
import '../models/module_item.dart'; // İlgi alanlarını (Kültür, Restoran vb.) çekmek için

// Bu ekranın durumu (seçilen saat, seçilen ilgi alanları) olacağı için StatefulWidget'a çeviriyoruz
class RouteContent extends StatefulWidget {
  const RouteContent({super.key});

  @override
  State<RouteContent> createState() => _RouteContentState();
}

class _RouteContentState extends State<RouteContent> {
  // Kullanıcının seçimlerini tutacak değişkenler
  double _selectedHours = 3; // Varsayılan süre 3 saat
  final Set<String> _selectedInterests = {}; // Seçilen ilgi alanları (başlangıçta boş)

  @override
  Widget build(BuildContext context) {
    // Ekranın üst ve alt boşluklarını hesapla (AppBar ve BottomNav için)
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    final double bottomNavHeight = kBottomNavigationBarHeight;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: statusBarHeight + appBarHeight + 10, 
        bottom: bottomNavHeight + 20, 
        left: 16.0,
        right: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- 1. Başlık ---
          Text(
            "AI Rota Oluşturucu",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Beyaz Yazı
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Ne kadar vaktin var ve nelerle ilgileniyorsun? Sana özel bir plan hazırlayalım.",
            style: TextStyle(color: Colors.white70, fontSize: 16), // Soluk Beyaz Yazı
          ),
          const SizedBox(height: 30),

          // --- 2. Süre Seçimi (Slider) ---
          _buildSectionContainer(
            context,
            title: "1. Ne Kadar Vaktin Var?",
            child: Column(
              children: [
                Slider(
                  value: _selectedHours,
                  min: 1, // Minimum 1 saat
                  max: 12, // Maksimum 12 saat
                  divisions: 11, // 1 saatlik artışlar
                  label: "${_selectedHours.round()} Saat",
                  activeColor: Colors.white, // Slider rengi
                  inactiveColor: Colors.white30,
                  onChanged: (double value) {
                    setState(() {
                      _selectedHours = value;
                    });
                  },
                ),
                Text(
                  "${_selectedHours.round()} Saat",
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),

          // --- 3. İlgi Alanı Seçimi (Chips) ---
          _buildSectionContainer(
            context,
            title: "2. İlgi Alanların Neler?",
            child: Wrap(
              spacing: 10.0, // Yatay boşluk
              runSpacing: 10.0, // Dikey boşluk
              children: allModules.map((module) {
                // 'allModules' listesini module_item.dart'tan alıyoruz
                final bool isSelected = _selectedInterests.contains(module.title);
                return FilterChip(
                  label: Text(module.title),
                  avatar: Icon(module.icon, size: 18),
                  selected: isSelected,
                  backgroundColor: Colors.black.withOpacity(0.3),
                  selectedColor: Colors.white, // Seçilince Beyaz
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white, // Seçilince Siyah yazı
                  ),
                  checkmarkColor: Colors.black,
                  side: BorderSide(color: Colors.white.withOpacity(0.5)),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedInterests.add(module.title);
                      } else {
                        _selectedInterests.remove(module.title);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 40),

          // --- 4. Rota Oluştur Butonu ---
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.psychology, color: Colors.black),
              label: const Text(
                "Rotamı Oluştur",
                style: TextStyle(
                  color: Colors.black, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Beyaz Buton
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // TODO: AI Backend'e API çağrısı yapılacak
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "AI Rota Oluşturuluyor...\nSüre: ${_selectedHours.round()} saat\nİlgi Alanları: ${_selectedInterests.join(', ')}",
                    ),
                    backgroundColor: Colors.black,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Elemanları gruplamak için yarı-şeffaf bir kart oluşturan yardımcı fonksiyon
  Widget _buildSectionContainer(BuildContext context, {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // Opak Siyah Kart ile aynı stilde (%60 Siyah Opaklığı)
        color: Colors.black.withOpacity(0.6), 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 18, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}