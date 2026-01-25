// lib/main.dart 

import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Firebase Çekirdek ve Konfigürasyon Paketlerini Ekle
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // flutterfire configure ile otomatik oluşan dosya

// Ekranlar ve Modüller
import 'screens/main_app_scaffold.dart'; // Ana İskelet
import 'screens/poi_list_test_screen.dart'; // /culture rotası için kullanılacak ekran
import 'screens/food_poi_screen.dart'; // Kafe & Restoran Modülü Ekranı
import 'screens/lodging_poi_screen.dart'; // Konaklama Modülü Ekranı
import 'screens/health_poi_screen.dart'; // Eczane & Hastane Modülü Ekranı
import 'screens/city_guide_screen.dart'; // Şehir Rehberi Modülü Ekranı

// YENİ: Üniversite Seçim ve Detay Ekranları
import 'screens/university_select_screen.dart'; // Üniversite Seçim Ekranı (İsmi düzelttik)
import 'screens/university_detail_screen.dart'; // Üniversite Detay/Menü Ekranı

// EK MODÜL EKRANLARI (Üniversite Alt Menüsü için)
import 'screens/university_places_screen.dart'; // Üniversite Mekanlar Listesi
import 'screens/university_guide_info_screen.dart'; // Üniversite Rehber Bilgisi

// POI Detay Ekranı
import 'screens/poi_detail_screen.dart'; 

// 2. main fonksiyonunu async yap ve Firebase'i başlat
void main() async {
  // Uygulamanın widget'ları yüklenmeden önce Firebase'in başlatılmasını beklemek için gerekli
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Platforma özgü konfigürasyonlar kullanılarak Firebase'i başlat
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase başarıyla başlatıldı.");
  } catch (e) {
    // Başlatma hatası olursa debug konsoluna yazdır
    print("❌ Firebase başlatılırken hata oluştu: $e");
  }

  runApp(const ErzurumApp());
}

class ErzurumApp extends StatelessWidget {
  const ErzurumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erzurum Akıllı Şehir',
      debugShowCheckedModeBanner: false,

      // Ana Sayfa (Alt menüyü ve tüm sayfaları yöneten iskelet)
      home: const MainAppScaffold(),

      // ----------------------------------------------------------
      // UYGULAMA ROTLARI (MODULE_ITEM.DART İLE UYUMLU OLMALI)
      // ----------------------------------------------------------
      routes: {
        // Şehir Rehberi rotası
        '/city_guide': (context) => const CityGuideScreen(), 
        
        // KÜLTÜR MODÜLÜ ROTASI: '/culture'
        '/culture': (context) => const POIListTestScreen(),
        
        // Kafe & Restoran Modülü
        '/food': (context) => const FoodPoiScreen(), 
        
        // Konaklama Modülü
        '/lodging': (context) => const LodgingPoiScreen(),
        
        // Sağlık Modülü
        '/health': (context) => const HealthPoiScreen(),
        
        // ✅ KRİTİK DÜZELTME: Artık doğru sınıf ismini çağırıyor (Selection -> Select)
        '/universities': (context) => const UniversitySelectScreen(), 
        
        // Ulaşım rotası şimdilik yer tutucu olarak kaldı.
        '/transport': (context) => const TemporaryModuleScreen(title: "Toplu Taşıma"),
      },
      // ----------------------------------------------------------

      // --- DİNAMİK ROTA YÖNETİMİ (ÜNİVERSİTE DETAYLARI İÇİN) ---
      onGenerateRoute: (settings) {
        final universityId = settings.arguments as String?; // Argümanı string olarak al (atauni_kampus/etu_kampus)

        // 1. Üniversite Detay Menüsü (Seçim sonrası)
        if (settings.name == UniversityDetailScreen.routeName && universityId != null) {
          return MaterialPageRoute(
            builder: (context) {
              return UniversityDetailScreen(universityId: universityId);
            },
          );
        }
        
        // 2. Üniversite Mekanları Listesi
        if (settings.name == UniversityPlacesScreen.routeName && universityId != null) {
           return MaterialPageRoute(
            builder: (context) => UniversityPlacesScreen(universityId: universityId),
          );
        }

        // 3. Üniversite Rehber Bilgisi
        if (settings.name == UniversityGuideInfoScreen.routeName && universityId != null) {
           return MaterialPageRoute(
            builder: (context) => UniversityGuideInfoScreen(universityId: universityId),
          );
        }
        
        return null; // Tanımlanmış rotalarda değilse null döndür
      },

      // TEMA AYARLARI
      theme: FlexThemeData.dark(
        scheme: FlexScheme.greys, 
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorRadius: 20.0,
          elevatedButtonRadius: 15.0,
          textButtonRadius: 15.0,
          cardRadius: 20.0, 
          cardElevation: 0, 
        ),
      ).copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white, 
            fontSize: 24, 
            fontWeight: FontWeight.w600, 
            letterSpacing: 0.5, 
          ),
          iconTheme: IconThemeData(color: Colors.white, size: 28),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black.withOpacity(0.3),
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withOpacity(0.6),
          hintStyle: const TextStyle(color: Colors.white60),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
        ),
      ),
    );
  }
}

// Rotaların henüz ekranı yapılmamış modüller için geçici yer tutucu (placeholder)
class TemporaryModuleScreen extends StatelessWidget {
  final String title;
  const TemporaryModuleScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Arka plan rengi eklendi
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '$title Modülü Alt Yapısı Hazır.\nGeliştirme Bekleniyor.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }
}