import 'package:flutter/material.dart';
import '../models/module_item.dart'; // Modül verileri (allModules) buradan geliyor
import 'poi_list_test_screen.dart'; // Bu ekranı import etmesek de olur ama güvenli tarafta kalalım.
import 'package:lucide_icons/lucide_icons.dart'; // İkonlar için

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Uygulamanın arka planındaki gradient ile uyumlu olması için Scaffold'u kaldırıyoruz.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Üç sütunlu ızgara
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.85, 
        ),
        itemCount: allModules.length, // module_item.dart dosyasındaki listeyi kullanıyoruz
        itemBuilder: (context, index) {
          final module = allModules[index];
          return _ModuleCard(
            module: module,
            onTap: () {
              // Burası KÜLTÜR MODÜLÜ'ne (/culture) geçişi sağlar.
              Navigator.of(context).pushNamed(module.routeName);
            },
          );
        },
      ),
    );
  }
}

// Modül Kart Tasarımı
class _ModuleCard extends StatelessWidget {
  final ModuleItem module;
  final VoidCallback onTap;

  const _ModuleCard({required this.module, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4), // Koyu temaya uygun kart
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.white24, width: 1.5), 
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              module.icon,
              size: 40.0,
              color: Colors.white, 
            ),
            Text(
              module.title.split(' ')[0], 
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              module.title.split(' ').skip(1).join(' '), 
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}