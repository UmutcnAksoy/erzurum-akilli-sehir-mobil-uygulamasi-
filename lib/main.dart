import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_app_scaffold.dart';

void main() {
  runApp(const ErzurumApp());
}

class ErzurumApp extends StatelessWidget {
  const ErzurumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erzurum Akıllı Şehir',
      debugShowCheckedModeBanner: false,

      // ----------------------------------------------------------
      // PRO SEVİYE TEMA AYARLARI
      // ----------------------------------------------------------
      theme: FlexThemeData.dark(
        scheme: FlexScheme.greys, 
        useMaterial3: true,
        
        // Yazı Tipi: Poppins
        fontFamily: GoogleFonts.poppins().fontFamily,
        
        // Alt bileşenlerin profesyonel ayarları
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorRadius: 20.0,
          
          // Buton ve Kart ayarları (FlexColorScheme otomatik halleder)
          elevatedButtonRadius: 15.0,
          textButtonRadius: 15.0,
          cardRadius: 20.0, 
          cardElevation: 0, 
        ),
      ).copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        
        // Sayfa Geçiş Animasyonları
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),

        // AppBar Özelleştirme
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
        
        // Alt Menü 
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black.withOpacity(0.3),
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        ),
        
        // Input Alanı (Daha yumuşak kenarlar)
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
        
        // HATA VEREN cardTheme BLOĞU KALDIRILDI.
        // Hava durumu kartı zaten kendi dosyasında özelleştirildiği için buna gerek yok.
      ),

      home: const MainAppScaffold(),
    );
  }
}