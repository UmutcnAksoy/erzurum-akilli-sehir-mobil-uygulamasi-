import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/module_item.dart';
import '../screens/city_guide_screen.dart';
import '../screens/culture_poi_screen.dart';
import '../screens/transport_hub_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color lightText = Colors.white;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 24, bottom: 25),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erzurum Atlası',
                    style: TextStyle(
                      color: lightText,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Akıllı Şehir Rehberi',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // MODÜL LİSTESİ
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  ...allModules.map((module) => ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: Icon(module.icon, color: lightText, size: 22),
                    title: Text(
                      module.title,
                      style: const TextStyle(
                        color: lightText,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToModule(context, module);
                    },
                  )).toList(),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(color: Colors.white10, height: 30),
                  ),

                  // Bilgilendirme notu
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.info,
                            color: Colors.white38, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Modüller bilgilendirme ve tanıtım amaçlıdır.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ALT BİLGİ
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "v1.1.0 - Erzurum Edition",
                style: TextStyle(
                    color: Colors.white24, fontSize: 10, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToModule(BuildContext context, ModuleItem module) {
    final String titleLower = module.title.toLowerCase();

    if (titleLower.contains("şehir rehberi") ||
        titleLower.contains("tanıtım")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CityGuideScreen()));
      return;
    }

    if (titleLower.contains("kültür") || titleLower.contains("tarih")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CulturePoiScreen()));
      return;
    }

    if (titleLower.contains("toplu taşıma") ||
        titleLower.contains("otobüs")) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const TransportHubScreen()));
      return;
    }

    Navigator.of(context).pushNamed(module.routeName);
  }
}