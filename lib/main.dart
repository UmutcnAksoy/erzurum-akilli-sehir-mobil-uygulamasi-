import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/main_app_scaffold.dart';
import 'screens/poi_list_test_screen.dart';
import 'screens/food_poi_screen.dart';
import 'screens/lodging_poi_screen.dart';
import 'screens/health_poi_screen.dart';
import 'screens/city_guide_screen.dart';
import 'screens/university_select_screen.dart';
import 'screens/university_detail_screen.dart';
import 'screens/university_places_screen.dart';
import 'screens/university_guide_info_screen.dart';
import 'screens/poi_detail_screen.dart';
import 'screens/faculty_detail_screen.dart';
import 'models/university_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase başarıyla başlatıldı.");
  } catch (e) {
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
      home: const MainAppScaffold(),
      routes: {
        '/city_guide': (context) => const CityGuideScreen(),
        '/culture': (context) => const POIListTestScreen(),
        '/food': (context) => const FoodPoiScreen(),
        '/lodging': (context) => const LodgingPoiScreen(),
        '/health': (context) => const HealthPoiScreen(),
        '/universities': (context) => const UniversitySelectScreen(),
        '/transport': (context) =>
            const TemporaryModuleScreen(title: "Toplu Taşıma"),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/faculty_detail') {
          final faculty = settings.arguments as FacultyModel;
          return MaterialPageRoute(
            builder: (context) => FacultyDetailScreen(faculty: faculty),
          );
        }

        final universityId = settings.arguments as String?;

        if (settings.name == UniversityDetailScreen.routeName &&
            universityId != null) {
          return MaterialPageRoute(
            builder: (context) =>
                UniversityDetailScreen(universityId: universityId),
          );
        }

        if (settings.name == UniversityPlacesScreen.routeName &&
            universityId != null) {
          return MaterialPageRoute(
            builder: (context) =>
                UniversityPlacesScreen(universityId: universityId),
          );
        }

        if (settings.name == UniversityGuideInfoScreen.routeName &&
            universityId != null) {
          return MaterialPageRoute(
            builder: (context) =>
                UniversityGuideInfoScreen(universityId: universityId),
          );
        }

        return null;
      },
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
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withOpacity(0.6),
          hintStyle: const TextStyle(color: Colors.white60),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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

class TemporaryModuleScreen extends StatelessWidget {
  final String title;
  const TemporaryModuleScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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