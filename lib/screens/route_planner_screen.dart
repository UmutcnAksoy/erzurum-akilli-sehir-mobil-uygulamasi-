import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/route_model.dart';
import '../services/ai_service.dart';
import '../screens/maskot_screen.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _ozelMekanController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;
  List<RouteModel> _routes = [];
  int _selectedRouteIndex = 0;

  int? _sureDakika;
  String? _travelMode;
  List<String> _aktiviteler = [];
  String? _yemekTercih;
  String? _yemekZamani;
  List<String> _kacinilacaklar = [];
  String _ozelMekan = '';
  String? _havaDurumu;

  StreamSubscription<Position>? _positionStream;
  Set<String> _anlatilmisRotalar = {};

  @override
  void initState() {
    super.initState();
    _havaDurumuGetir();
    _kaydedilmisRotayiYukle();
  }

  Future<void> _kaydedilmisRotayiYukle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rotaJson = prefs.getString('aktif_rota');
      final travelMode = prefs.getString('aktif_travel_mode');
      final sureDakika = prefs.getInt('aktif_sure');
      if (rotaJson != null) {
        final decoded = jsonDecode(rotaJson);
        final routes = (decoded['rotalar'] as List)
            .map((r) => RouteModel.fromJson(r))
            .toList();
        setState(() {
          _routes = routes;
          _travelMode = travelMode ?? 'driving';
          _sureDakika = sureDakika ?? 120;
          _selectedRouteIndex = 0;
        });
        _startLocationTracking();
      }
    } catch (e) {
      print('❌ Rota yükleme hatası: $e');
    }
  }

  Future<void> _rotayiKaydet(List<RouteModel> routes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rotaJson = jsonEncode({
        'rotalar': routes.map((r) => r.toJson()).toList(),
      });
      await prefs.setString('aktif_rota', rotaJson);
      await prefs.setString('aktif_travel_mode', _travelMode ?? 'driving');
      await prefs.setInt('aktif_sure', _sureDakika ?? 120);
    } catch (e) {
      print('❌ Rota kaydetme hatası: $e');
    }
  }

  Future<void> _rotayiSil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('aktif_rota');
      await prefs.remove('aktif_travel_mode');
      await prefs.remove('aktif_sure');
    } catch (e) {
      print('❌ Rota silme hatası: $e');
    }
  }

  Future<void> _havaDurumuGetir() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();
      final apiKey = remoteConfig.getString('openweather_api_key');
      final weatherRes = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=39.9042&lon=41.2677&appid=$apiKey&units=metric&lang=tr'));
      if (weatherRes.statusCode == 200) {
        final wData = jsonDecode(weatherRes.body);
        final id = wData['weather'][0]['id'] as int;
        String durum;
        if (id >= 200 && id < 300) durum = 'fırtınalı';
        else if (id >= 300 && id < 600) durum = 'yağmurlu';
        else if (id >= 600 && id < 700) durum = 'karlı';
        else if (id >= 700 && id < 800) durum = 'sisli';
        else durum = 'açık';
        setState(() => _havaDurumu = durum);
      }
    } catch (e) {
      print('❌ Hava durumu alınamadı: $e');
    }
  }

  void _startLocationTracking() {
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((position) {
      _checkNearbyStops(position);
    });
  }

  void _stopLocationTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  void _checkNearbyStops(Position userPos) {
    if (_routes.isEmpty) return;
    final sorted = [..._routes]..sort((a, b) => b.enIyi ? 1 : -1);
    final aktifRota = sorted[_selectedRouteIndex];
    for (var durak in aktifRota.duraklar) {
      if (_anlatilmisRotalar.contains(durak.isim)) continue;
      try {
        final coords = durak.konum.split(',');
        if (coords.length < 2) continue;
        final durakLat = double.parse(coords[0].trim());
        final durakLng = double.parse(coords[1].trim());
        final mesafe = Geolocator.distanceBetween(
          userPos.latitude, userPos.longitude, durakLat, durakLng,
        );
        if (mesafe <= 150) {
          _anlatilmisRotalar.add(durak.isim);
          _yakinlikBildirimi(durak);
          break;
        }
      } catch (e) {}
    }
  }

  Future<void> _yakinlikBildirimi(RouteStop durak) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.cyanAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(durak.isim,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(
          "${durak.isim}'e hos geldiniz! Sesli rehber baslatilsin mi?",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hayir", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MaskotScreen(baslangicMekan: durak.isim),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Evet, Baslat!",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopLocationTracking();
    _ozelMekanController.dispose();
    super.dispose();
  }

  List<RouteModel>? _parseRoutes(String response) {
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) return null;
      final jsonStr = response.substring(jsonStart, jsonEnd + 1);
      final decoded = jsonDecode(jsonStr);
      if (decoded['rotalar'] != null) {
        return (decoded['rotalar'] as List)
            .map((r) => RouteModel.fromJson(r))
            .toList();
      }
    } catch (e) {}
    return null;
  }

  void _createRoute() async {
    setState(() {
      _isLoading = true;
      _routes = [];
      _currentStep = 7;
      _anlatilmisRotalar = {};
    });

    final response = await _aiService.askToErzurumAI(
      '',
      travelMode: _travelMode ?? 'driving',
      havaDurumu: _havaDurumu,
      yemekTercih: _yemekTercih,
      yemekZamani: _yemekZamani,
      kacinilacaklar: _kacinilacaklar,
      aktiviteler: _aktiviteler,
      ozelMekan: _ozelMekan,
      sureDakika: _sureDakika ?? 120,
    );

    final routes = _parseRoutes(response);
    setState(() {
      _routes = routes ?? [];
      _selectedRouteIndex = 0;
      _isLoading = false;
    });

    if (_routes.isNotEmpty) {
      _startLocationTracking();
      await _rotayiKaydet(_routes);
    }
  }

  void _reset() {
    _stopLocationTracking();
    _rotayiSil();
    setState(() {
      _currentStep = 0;
      _sureDakika = null;
      _travelMode = null;
      _aktiviteler = [];
      _yemekTercih = null;
      _yemekZamani = null;
      _kacinilacaklar = [];
      _ozelMekan = '';
      _routes = [];
      _anlatilmisRotalar = {};
      _ozelMekanController.clear();
    });
  }

  void _yenidenPlanlaDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Yeniden Planla",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          "Oluşturulan rota silinecek ve baştan planlamaya başlayacaksın. Devam etmek istiyor musun?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Vazgeç",
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _reset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Evet, Yeniden Planla",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _duragaGit(RouteStop durak) async {
    final mode = _travelMode == 'walking' ? 'walking' : 'driving';
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${durak.konum}&travelmode=$mode',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _buildShareText(RouteModel route) {
    final buffer = StringBuffer();
    buffer.writeln("🗺️ Erzurum Rotam - ${route.baslik}");
    buffer.writeln("⏱️ Süre: ${route.sure}");
    buffer.writeln("📍 Duraklar:");
    for (int i = 0; i < route.duraklar.length; i++) {
      buffer.writeln("${i + 1}. ${route.duraklar[i].isim}");
    }
    buffer.writeln("\n📱 Erzurum Atlası");
    return buffer.toString();
  }

  String? _getTransportWarning(RouteStop current, RouteStop next) {
    try {
      final c = current.konum.split(',');
      final n = next.konum.split(',');
      if (c.length < 2 || n.length < 2) return null;
      final dlat = (double.parse(c[0]) - double.parse(n[0])).abs();
      final dlng = (double.parse(c[1]) - double.parse(n[1])).abs();
      final distKm = (dlat * 111 + dlng * 75) / 2;
      if (_travelMode == 'driving' && distKm < 0.5) {
        return '🚶 Yürüme mesafesinde (${(distKm * 1000).toInt()}m), yürümeyi düşünebilirsin!';
      } else if (_travelMode == 'walking' && distKm > 1.5) {
        return '🚗 Biraz uzak (${distKm.toStringAsFixed(1)}km), araç düşünebilirsin!';
      }
    } catch (e) {}
    return null;
  }

  IconData _stopIcon(String tur) {
    switch (tur) {
      case 'yemek': return Icons.restaurant;
      case 'kultur': return Icons.museum;
      case 'universite': return Icons.school;
      case 'otel': return Icons.hotel;
      case 'saglik': return Icons.local_hospital;
      default: return Icons.location_on;
    }
  }

  Color _stopColor(String tur) {
    switch (tur) {
      case 'yemek': return Colors.orange;
      case 'kultur': return Colors.purple;
      case 'universite': return Colors.blue;
      case 'otel': return Colors.teal;
      case 'saglik': return Colors.red;
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(top: statusBarHeight + appBarHeight),
        child: _isLoading
            ? _buildLoading()
            : _routes.isNotEmpty
                ? _buildRoutes()
                : _buildSteps(),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.blueAccent),
          const SizedBox(height: 20),
          const Text(
            "Rotalar hesaplanıyor...",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          if (_havaDurumu != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wb_cloudy, color: Colors.blueAccent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "Hava: $_havaDurumu — rotana yansıtılıyor",
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSteps() {
    switch (_currentStep) {
      case 0: return _buildSureStep();
      case 1: return _buildUlasimStep();
      case 2: return _buildAktiviteStep();
      case 3: return _buildYemekStep();
      case 4: return _buildYemekZamaniStep();
      case 5: return _buildKacinilacaklarStep();
      case 6: return _buildOzelMekanStep();
      default: return _buildLoading();
    }
  }

  Widget _buildSureStep() {
    return _buildStepContainer(
      icon: Icons.access_time,
      title: "Kaç saatiniz var?",
      subtitle: "Rotanı süreye göre planlayalım",
      child: Column(
        children: [
          if (_havaDurumu != null && _havaDurumu != 'açık')
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_cloudy, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Bugün hava $_havaDurumu. İç mekan rotası önerilecek.",
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          _buildOptionButton("1 Saat", Icons.looks_one, Colors.blueAccent,
              () => setState(() { _sureDakika = 60; _currentStep = 1; })),
          _buildOptionButton("2 Saat", Icons.looks_two, Colors.blueAccent,
              () => setState(() { _sureDakika = 120; _currentStep = 1; })),
          _buildOptionButton("3 Saat", Icons.looks_3, Colors.blueAccent,
              () => setState(() { _sureDakika = 180; _currentStep = 1; })),
          _buildOptionButton("4 Saat", Icons.looks_4, Colors.blueAccent,
              () => setState(() { _sureDakika = 240; _currentStep = 1; })),
          _buildOptionButton("Yarım Gün (5+ Saat)", Icons.wb_sunny, Colors.orange,
              () => setState(() { _sureDakika = 300; _currentStep = 1; })),
        ],
      ),
    );
  }

  Widget _buildUlasimStep() {
    return _buildStepContainer(
      icon: Icons.directions,
      title: "Nasıl seyahat edeceksiniz?",
      subtitle: "Ulaşım moduna göre en uygun mekanları seçelim",
      child: Column(
        children: [
          _buildOptionButton("Araçla", Icons.directions_car, Colors.blueAccent,
              () => setState(() { _travelMode = 'driving'; _currentStep = 2; })),
          _buildOptionButton("Yürüyerek", Icons.directions_walk, Colors.greenAccent,
              () => setState(() { _travelMode = 'walking'; _currentStep = 2; })),
          _buildOptionButton("Karışık (Arabam var, kısa mesafe yürürüm)",
              Icons.swap_horiz, Colors.orangeAccent,
              () => setState(() { _travelMode = 'mixed'; _currentStep = 2; })),
        ],
      ),
    );
  }

  Widget _buildAktiviteStep() {
    return _buildStepContainer(
      icon: Icons.explore,
      title: "Ne yapmak istersiniz?",
      subtitle: "Birden fazla seçebilirsiniz",
      child: Column(
        children: [
          _buildMultiSelectButton("Kültürel Yerler", Icons.museum, Colors.purple, 'kultur'),
          _buildMultiSelectButton("Doğa & Parklar", Icons.park, Colors.green, 'doga'),
          _buildMultiSelectButton("Alışveriş", Icons.shopping_bag, Colors.pink, 'alisveris'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _aktiviteler.isEmpty
                  ? null
                  : () => setState(() => _currentStep = 3),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                disabledBackgroundColor: Colors.white12,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Devam Et",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYemekStep() {
    return _buildStepContainer(
      icon: Icons.restaurant,
      title: "Yemek yiyecek misiniz?",
      subtitle: "Tercihine göre en iyi mekanı bulalım",
      child: Column(
        children: [
          _buildOptionButton("Cağ Kebap", Icons.lunch_dining, Colors.red,
              () => setState(() { _yemekTercih = 'cağ kebap'; _currentStep = 4; })),
          _buildOptionButton("Kahvaltı", Icons.free_breakfast, Colors.orange,
              () => setState(() { _yemekTercih = 'kahvaltı'; _currentStep = 4; })),
          _buildOptionButton("Kafe / Çay", Icons.coffee, Colors.brown,
              () => setState(() { _yemekTercih = 'kafe'; _currentStep = 4; })),
          _buildOptionButton("Döner", Icons.kebab_dining, Colors.deepOrange,
              () => setState(() { _yemekTercih = 'döner'; _currentStep = 4; })),
          _buildOptionButton("Tatlı / Kadayıf", Icons.cake, Colors.pinkAccent,
              () => setState(() { _yemekTercih = 'tatlı'; _currentStep = 4; })),
          _buildOptionButton("Fark Etmez", Icons.restaurant_menu, Colors.blueGrey,
              () => setState(() { _yemekTercih = 'fark etmez'; _currentStep = 4; })),
          _buildOptionButton("Yemek Yemeyeceğim", Icons.no_meals, Colors.grey,
              () => setState(() { _yemekTercih = 'hayir'; _currentStep = 5; })),
        ],
      ),
    );
  }

  Widget _buildYemekZamaniStep() {
    return _buildStepContainer(
      icon: Icons.schedule,
      title: "Yemeği ne zaman yemek istersiniz?",
      subtitle: "Rotanızı buna göre düzenleyelim",
      child: Column(
        children: [
          _buildOptionButton("Geziye Başlamadan Önce",
              Icons.wb_sunny_outlined, Colors.orange,
              () => setState(() { _yemekZamani = 'once'; _currentStep = 5; })),
          _buildOptionButton("Gezerken (Güzergaha Göre)",
              Icons.route, Colors.blueAccent,
              () => setState(() { _yemekZamani = 'sirasinda'; _currentStep = 5; })),
          _buildOptionButton("Gezi Bittikten Sonra",
              Icons.nights_stay, Colors.purple,
              () => setState(() { _yemekZamani = 'sonra'; _currentStep = 5; })),
          _buildOptionButton("Fark Etmez",
              Icons.shuffle, Colors.blueGrey,
              () => setState(() { _yemekZamani = 'fark_etmez'; _currentStep = 5; })),
        ],
      ),
    );
  }

  Widget _buildKacinilacaklarStep() {
    return _buildStepContainer(
      icon: Icons.do_not_disturb,
      title: "Kaçınmak istediğiniz yer var mı?",
      subtitle: "Rotanda görmek istemediğin yerleri seç",
      child: Column(
        children: [
          _buildMultiSelectButton("Dini Mekanlar", Icons.mosque, Colors.teal, 'dini'),
          _buildMultiSelectButton("Müzeler", Icons.museum, Colors.indigo, 'muze'),
          _buildMultiSelectButton("Doğa / Park", Icons.park, Colors.green, 'doga_kacin'),
          _buildMultiSelectButton("Alışveriş Merkezleri", Icons.shopping_bag, Colors.pink, 'alisveris_kacin'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 6),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Devam Et",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => setState(() {
                _kacinilacaklar = [];
                _currentStep = 6;
              }),
              child: const Text("Kaçınmak istediğim yer yok",
                  style: TextStyle(color: Colors.white54)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOzelMekanStep() {
    return _buildStepContainer(
      icon: Icons.place,
      title: "Özel bir yer var mı?",
      subtitle: "Mutlaka gitmek istediğin bir mekan varsa yaz",
      child: Column(
        children: [
          TextField(
            controller: _ozelMekanController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Örn: Yakutiye Medresesi, Çifte Minareli...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _ozelMekan = _ozelMekanController.text.trim());
                _createRoute();
              },
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text("Rotamı Oluştur!",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                setState(() => _ozelMekan = '');
                _createRoute();
              },
              child: const Text("Özel yer yok, direkt oluştur",
                  style: TextStyle(color: Colors.white54)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContainer({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final steps = ['Süre', 'Ulaşım', 'Aktivite', 'Yemek', 'Zaman', 'Kaçın', 'Mekan'];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(steps.length, (i) {
              final isActive = i == _currentStep;
              final isDone = i < _currentStep;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.blueAccent
                        : isActive
                            ? Colors.blueAccent.withOpacity(0.6)
                            : Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '${_currentStep + 1}/${steps.length} - ${steps[_currentStep]}',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.blueAccent, size: 32),
                const SizedBox(height: 12),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
          if (_currentStep > 0)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton.icon(
                onPressed: () => setState(() => _currentStep--),
                icon: const Icon(Icons.arrow_back, color: Colors.white38, size: 16),
                label: const Text("Geri",
                    style: TextStyle(color: Colors.white38)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectButton(
      String label, IconData icon, Color color, String value) {
    final isKacin = value == 'dini' ||
        value == 'muze' ||
        value == 'doga_kacin' ||
        value == 'alisveris_kacin';
    final list = isKacin ? _kacinilacaklar : _aktiviteler;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (list.contains(value)) {
            list.remove(value);
          } else {
            list.add(value);
          }
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: list.contains(value)
              ? color.withOpacity(0.25)
              : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: list.contains(value) ? color : color.withOpacity(0.2),
              width: list.contains(value) ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
            ),
            Icon(
              list.contains(value)
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: list.contains(value) ? color : color.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutes() {
    final sorted = [..._routes]..sort((a, b) => b.enIyi ? 1 : -1);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              const Expanded(
                child: Text("Rota Önerilerim",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              TextButton.icon(
                onPressed: _yenidenPlanlaDialog,
                icon: const Icon(Icons.refresh, color: Colors.white54, size: 16),
                label: const Text("Yeniden Planla",
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.my_location, color: Colors.green, size: 14),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  "Konum takibi aktif - Mekana yaklaşınca bildirim alacaksın",
                  style: TextStyle(color: Colors.green, fontSize: 11),
                ),
              ),
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 14),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  "Bu rotalar yapay zeka tarafından oluşturulmuştur, hatalar içerebilir.",
                  style: TextStyle(color: Colors.orange, fontSize: 11),
                ),
              ),
            ],
          ),
        ),

        if (_havaDurumu != null && _havaDurumu != 'açık')
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_cloudy, color: Colors.blueAccent, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "Hava $_havaDurumu — iç mekan mekanlar öne alındı",
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _summaryChip(Icons.access_time,
                  '${_sureDakika! ~/ 60} saat${_sureDakika! % 60 > 0 ? ' ${_sureDakika! % 60}dk' : ''}'),
              _summaryChip(
                  _travelMode == 'driving'
                      ? Icons.directions_car
                      : _travelMode == 'walking'
                          ? Icons.directions_walk
                          : Icons.swap_horiz,
                  _travelMode == 'driving'
                      ? 'Araçla'
                      : _travelMode == 'walking'
                          ? 'Yürüyerek'
                          : 'Karışık'),
              if (_yemekTercih != null && _yemekTercih != 'hayir')
                _summaryChip(Icons.restaurant, _yemekTercih!),
              if (_ozelMekan.isNotEmpty)
                _summaryChip(Icons.place, _ozelMekan),
            ],
          ),
        ),

        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedRouteIndex == index;
              final route = sorted[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedRouteIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (route.enIyi ? Colors.amber : Colors.blueAccent)
                        : Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24),
                  ),
                  child: Row(
                    children: [
                      if (route.enIyi)
                        const Icon(Icons.star, color: Colors.white, size: 14),
                      if (route.enIyi) const SizedBox(width: 4),
                      Text(route.baslik,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Expanded(child: _buildRouteDetail(sorted[_selectedRouteIndex])),
      ],
    );
  }

  Widget _summaryChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white60, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRouteDetail(RouteModel route) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: route.enIyi ? Colors.amber : Colors.white12,
                width: route.enIyi ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                if (route.enIyi)
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                if (route.enIyi) const SizedBox(width: 6),
                Expanded(
                  child: Text(route.aciklama,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(route.sure,
                      style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...route.duraklar.asMap().entries.map((entry) {
            final i = entry.key;
            final durak = entry.value;
            final nextDurak = i < route.duraklar.length - 1
                ? route.duraklar[i + 1]
                : null;
            final warning = nextDurak != null
                ? _getTransportWarning(durak, nextDurak)
                : null;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _stopColor(durak.tur),
                            child: Icon(_stopIcon(durak.tur),
                                size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(durak.isim,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(durak.sure,
                                    style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Text('${i + 1}. durak',
                              style: const TextStyle(
                                  color: Colors.white30, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _duragaGit(durak),
                          icon: const Icon(Icons.navigation, size: 16),
                          label: Text(
                            i == route.duraklar.length - 1
                                ? "Son Durağa Git"
                                : "${i + 1}. Durağa Git",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < route.duraklar.length - 1)
                  Column(
                    children: [
                      Container(
                          height: 16, width: 2, color: Colors.white24),
                      if (warning != null)
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.orange, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(warning,
                                    style: const TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      Container(
                          height: 16, width: 2, color: Colors.white24),
                    ],
                  ),
              ],
            );
          }).toList(),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Share.share(_buildShareText(route)),
              icon: const Icon(Icons.share),
              label: const Text("Rotayı Paylaş"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}