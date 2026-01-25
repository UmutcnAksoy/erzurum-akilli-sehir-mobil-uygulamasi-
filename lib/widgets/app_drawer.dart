import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/module_item.dart'; 

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // AMAÇ: Drawer'ı, Ana Sayfa'daki (Dashboard) koyu gradient ile uyumlu, şık bir koyu şeffaf tona geri döndürmek.
    const Color lightText = Colors.white; // Koyu zeminde kullanılacak metin rengi

    return Drawer(
      // Drawer'ın kendisini tamamen şeffaf yapıyoruz.
      backgroundColor: Colors.transparent, 
      elevation: 0, 

      child: Container(
        // Drawer içeriği için KOYU, hafif şeffaf bir arka plan ekliyoruz.
        // Bu renk, ana sayfanın genel temasıyla uyumludur.
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8), // Koyu şeffaflık (%80 opaklık)
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Drawer Başlığı: Temiz, koyu şeffaf arkaplan üzerinde BEYAZ metin
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, bottom: 20), 
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3), // Başlık arka planını hafifçe vurguluyoruz
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erzurum Atlası Hizmetleri',
                    style: TextStyle(
                      color: lightText, 
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tüm Modüllere Hızlı Erişim',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // --- TÜM MODÜLLERİN LİSTELENMESİ (BEYAZ YAZI İLE) ---
            ...allModules.map((module) => ListTile(
              tileColor: Colors.transparent, 
              // Hover/tıklama rengini beyazın hafif şeffaf tonu yaptık
              hoverColor: lightText.withOpacity(0.1),
              leading: Icon(
                module.icon, 
                color: lightText, // BEYAZ İKON
              ),
              title: Text(
                module.title,
                style: const TextStyle(color: lightText, fontWeight: FontWeight.w500), 
              ),
              onTap: () {
                Navigator.pop(context); 
                Navigator.of(context).pushNamed(module.routeName);
              },
            )).toList(),
            
            // --- AYIRICI ÇİZGİ ---
            const Divider(color: Colors.white24),

            // --- EK SEÇENEKLER ---
            ListTile(
              tileColor: Colors.transparent,
              hoverColor: lightText.withOpacity(0.1),
              leading: const Icon(LucideIcons.settings, color: Colors.white70),
              title: const Text('Ayarlar', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}