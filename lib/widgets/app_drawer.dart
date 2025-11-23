// lib/widgets/app_drawer.dart (NİHAİ KOD - RENKLERİ ZORLA)

import 'package:flutter/material.dart';
import '../models/module_item.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // 1. ADIM: Drawer'ın arkaplanını BEYAZ yapmaya zorla
      backgroundColor: Colors.white, 
      
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // 2. ADIM: Başlık SİYAH
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black, 
            ),
            child: Text(
              'Erzurum Hizmet Modülleri',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 24,
              ),
            ),
          ),
          
          // 3. ADIM: Liste elemanlarını SİYAH yapmaya zorla
          ...allModules.map((module) => ListTile(
            leading: Icon(
              module.icon, 
              // Temadan gelen beyazı ez, siyah yap
              color: Colors.black.withOpacity(0.7), 
            ), 
            title: Text(
              module.title,
              // Temadan gelen beyazı ez, siyah yap
              style: const TextStyle(color: Colors.black), 
            ),
            onTap: () {
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${module.title} modülü açılacak.')),
              );
            },
          )).toList(),
        ],
      ),
    );
  }
}