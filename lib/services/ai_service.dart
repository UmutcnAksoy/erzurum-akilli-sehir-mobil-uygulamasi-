import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class AiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _groqUrl = "https://api.groq.com/openai/v1/chat/completions";

  String? _havaDurumu;
  bool _icMekanOncelikli = false;
  List<Map<String, dynamic>>? _kulturCache;
  List<Map<String, dynamic>>? _yemekCache;

  void setHavaDurumu(String durum) {
    _havaDurumu = durum;
    final kapaliHavalar = ['karlı', 'yağmurlu', 'fırtınalı', 'sisli', 'çiseleyen'];
    _icMekanOncelikli =
        kapaliHavalar.any((k) => durum.toLowerCase().contains(k));
  }

  Future<String> _getGroqKey() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.fetchAndActivate();
      final key = remoteConfig.getString('groq_api_key');
      if (key.isNotEmpty) return key;
    } catch (e) {
      print('❌ Remote Config: $e');
    }
    return '';
  }

  Future<Position?> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));
      final isEmulator =
          pos.latitude > 36 && pos.latitude < 38 && pos.longitude < 0;
      if (isEmulator) return null;
      return pos;
    } catch (e) {
      return null;
    }
  }

  Future<void> _verileriYukle() async {
    if (_kulturCache != null && _yemekCache != null) return;
    final results = await Future.wait([
      _db.collection('city_guide').get(),
      _db.collection('food_places').get(),
    ]);
    _kulturCache = results[0].docs
        .map((d) => {...d.data(), 'id': d.id})
        .where((p) => p['location'] is GeoPoint)
        .toList()
        .cast<Map<String, dynamic>>();
    _yemekCache = results[1].docs
        .map((d) => {...d.data(), 'id': d.id})
        .where((p) => p['location'] is GeoPoint)
        .toList()
        .cast<Map<String, dynamic>>();
    print('✅ Cache: ${_kulturCache!.length} kültür, ${_yemekCache!.length} yemek');
  }

  // Nearest-neighbor algoritması - BİZ hesaplıyoruz
  List<Map<String, dynamic>> _nearestNeighborSirala(
    List<Map<String, dynamic>> mekanlar,
    double startLat,
    double startLng,
  ) {
    if (mekanlar.isEmpty) return [];
    final remaining = List<Map<String, dynamic>>.from(mekanlar);
    final sorted = <Map<String, dynamic>>[];
    double curLat = startLat, curLng = startLng;

    while (remaining.isNotEmpty) {
      double minDist = double.infinity;
      int nearestIdx = 0;

      for (int i = 0; i < remaining.length; i++) {
        final loc = remaining[i]['location'] as GeoPoint;
        final dist = Geolocator.distanceBetween(
            curLat, curLng, loc.latitude, loc.longitude);
        if (dist < minDist) {
          minDist = dist;
          nearestIdx = i;
        }
      }

      final nearest = remaining[nearestIdx];
      final loc = nearest['location'] as GeoPoint;
      sorted.add({...nearest, '_distFromPrev': minDist.toInt()});
      curLat = loc.latitude;
      curLng = loc.longitude;
      remaining.removeAt(nearestIdx);
    }

    return sorted;
  }

  double _mekanSkoru(
    Map<String, dynamic> mekan,
    double userLat,
    double userLng,
    List<String> aktiviteler,
    String ozelMekan,
    double? merkezLat,
    double? merkezLng,
    List<String> kacinilacaklar,
  ) {
    final loc = mekan['location'] as GeoPoint;
    final rating = (mekan['rating'] ?? 3.0) as num;
    final kategori = (mekan['category'] ?? '').toString().toLowerCase();
    final isim = (mekan['name'] ?? '').toString().toLowerCase();

    final refLat = merkezLat ?? userLat;
    final refLng = merkezLng ?? userLng;
    final mesafe = Geolocator.distanceBetween(
        refLat, refLng, loc.latitude, loc.longitude);

    final mesafeSkor = mesafe == 0 ? 1000.0 : 10000.0 / mesafe;
    final popularlikSkor = rating.toDouble() * 5;

    double aktiviteSkor = 0;
    if (aktiviteler.contains('kultur') &&
        ['culture', 'museum', 'religious'].contains(kategori)) {
      aktiviteSkor = 50;
    }
    if (aktiviteler.contains('doga') &&
        ['nature', 'sport'].contains(kategori)) {
      aktiviteSkor = 50;
    }
    if (aktiviteler.contains('alisveris') && kategori == 'shopping') {
      aktiviteSkor = 50;
    }

    double havaSkor = 0;
    if (_icMekanOncelikli) {
      if (['museum', 'culture', 'religious'].contains(kategori)) {
        havaSkor = 30;
      } else {
        havaSkor = -50;
      }
    }

    double ozelSkor = 0;
    if (ozelMekan.isNotEmpty && isim.contains(ozelMekan.toLowerCase())) {
      ozelSkor = 1000;
    }

    double kacinSkor = 0;
    if (kacinilacaklar.contains('dini') && kategori == 'religious') {
      kacinSkor = -500;
    }
    if (kacinilacaklar.contains('muze') && kategori == 'museum') {
      kacinSkor = -500;
    }
    if (kacinilacaklar.contains('doga_kacin') &&
        ['nature', 'sport'].contains(kategori)) {
      kacinSkor = -500;
    }
    if (kacinilacaklar.contains('alisveris_kacin') && kategori == 'shopping') {
      kacinSkor = -500;
    }

    return mesafeSkor + popularlikSkor + aktiviteSkor + havaSkor +
        ozelSkor + kacinSkor;
  }

  Map<String, double>? _ozelMekanKoordinat(String ozelMekan) {
    if (ozelMekan.isEmpty) return null;
    for (var mekan in _kulturCache!) {
      final isim = (mekan['name'] ?? '').toString().toLowerCase();
      if (isim.contains(ozelMekan.toLowerCase())) {
        final loc = mekan['location'] as GeoPoint;
        return {'lat': loc.latitude, 'lng': loc.longitude};
      }
    }
    return null;
  }

  String _buildPrompt({
    required double startLat,
    required double startLng,
    required int sureDakika,
    required String travelMode,
    required String? yemekTercih,
    required String? yemekZamani,
    required List<String> aktiviteler,
    required List<String> kacinilacaklar,
    required String ozelMekan,
    required List<Map<String, dynamic>> siraliKultur,
    required List<Map<String, dynamic>> siraliYemek,
    double? ozelMekanLat,
    double? ozelMekanLng,
  }) {
    final yemekVar = yemekTercih != null && yemekTercih != 'hayir';
    final buffer = StringBuffer();
    final hasOzelMekan = ozelMekan.isNotEmpty;

    final travelStr = travelMode == 'driving'
        ? 'ARAÇLA (ulasim="driving")'
        : travelMode == 'walking'
            ? 'YÜRÜYEREK (ulasim="walking", max 2km)'
            : 'KARMA (500m altı ulasim="walking", üzeri ulasim="driving")';

    final aktiviteStr = aktiviteler.contains('kultur')
        ? 'Kültür/Tarihi/Müze (culture, museum, religious)'
        : aktiviteler.contains('doga')
            ? 'Doğa/Park/Spor (nature, sport)'
            : aktiviteler.contains('alisveris')
                ? 'Alışveriş (shopping)'
                : 'Genel';

    String yemekZamaniStr = '';
    if (yemekVar && yemekZamani != null) {
      switch (yemekZamani) {
        case 'once': yemekZamaniStr = 'İLK DURAK olsun!'; break;
        case 'sonra': yemekZamaniStr = 'SON DURAK olsun!'; break;
        case 'sirasinda': yemekZamaniStr = 'Güzergahın en mantıklı yerine koy!'; break;
        case 'fark_etmez': yemekZamaniStr = 'Güzergaha göre karar ver!'; break;
      }
    }

    String kacinStr = '';
    if (kacinilacaklar.isNotEmpty) {
      final list = <String>[];
      if (kacinilacaklar.contains('dini')) list.add('dini mekanlar');
      if (kacinilacaklar.contains('muze')) list.add('müzeler');
      if (kacinilacaklar.contains('doga_kacin')) list.add('doğa/park');
      if (kacinilacaklar.contains('alisveris_kacin')) list.add('alışveriş');
      kacinStr = list.join(', ');
    }

    final tahminiMekan = travelMode == 'walking'
        ? ((sureDakika - (yemekVar ? 60 : 0)) / 57).floor().clamp(1, 6)
        : ((sureDakika - (yemekVar ? 60 : 0)) / 48).floor().clamp(1, 8);

    buffer.writeln("""Sen deneyimli bir Erzurum tur rehberi asistanısın.

=== KULLANICI KRİTERLERİ ===
Başlangıç: $startLat,$startLng
Süre: $sureDakika dakika (AŞMA!)
Ulaşım: $travelStr
Aktivite: $aktiviteStr
${hasOzelMekan ? 'ÖZEL MEKAN: "$ozelMekan" → 3 ROTADA DA MUTLAKA EKLE!' : ''}
${yemekVar ? 'Yemek: $yemekTercih → $yemekZamaniStr' : 'Yemek: İstemiyorum'}
${kacinStr.isNotEmpty ? 'KAÇINILACAKLAR: $kacinStr → Bunları rotaya EKLEME!' : ''}
${_icMekanOncelikli ? 'HAVA KÖTÜ: Sadece kapalı alan seç!' : _havaDurumu != null ? 'Hava: $_havaDurumu' : ''}

=== ÖNEMLİ: MEKAN SIRASI ===
Aşağıdaki mekanlar ZATEN nearest-neighbor algoritmasıyla sıralanmış.
Yani her mekan bir öncekine en yakın olandır.
Bu sırayı MUTLAKA takip et! Kendi sıralamanı yapma!
Sıra numarası küçük olan = kullanıcıya daha yakın = önce git.

Tahminen $tahminiMekan mekan sığar. Bu listeyi baştan alarak sığanları seç.

=== KÜLTÜR MEKANLARI (nearest-neighbor sırasıyla) ===
(SIRA|İSİM|KOORDİNAT|ÖNCEKİ_DURAKTAN_MESAFE|GEZİ_SÜRESİ|KATEGORİ)
""");

    for (int i = 0; i < siraliKultur.length; i++) {
      final p = siraliKultur[i];
      final loc = p['location'] as GeoPoint;
      final dist = p['_distFromPrev'] ?? 0;
      final distStr = (dist as int) < 1000
          ? '${dist}m'
          : '${(dist / 1000).toStringAsFixed(1)}km';
      buffer.writeln(
          "${i + 1}|${p['name'] ?? p['id']}|${loc.latitude},${loc.longitude}|$distStr|${p['visit_duration'] ?? 45}dk|${p['category'] ?? 'culture'}");
    }

    if (yemekVar && siraliYemek.isNotEmpty) {
      buffer.writeln("""
=== YEMEK MEKANLARI (yakınlık+puan sırasıyla) ===
(PUAN|İSİM|KOORDİNAT|UZAKLIK)
""");
      for (var p in siraliYemek) {
        final loc = p['location'] as GeoPoint;
        final dist = p['_distFromPrev'] ?? 0;
        final distStr = (dist as int) < 1000
            ? '${dist}m'
            : '${(dist / 1000).toStringAsFixed(1)}km';
        buffer.writeln(
            "${p['rating'] ?? '-'}⭐|${p['name']}|${loc.latitude},${loc.longitude}|$distStr");
      }
    }

    buffer.writeln("""
=== ROTA OLUŞTURMA KURALLARI ===

ÇOK ÖNEMLİ: Mekan listesi nearest-neighbor sırasında verildi.
Bu sırayı takip et! 1. mekan → 2. mekan → 3. mekan şeklinde git.
Sırayı atlama veya değiştirme!

Rota 1 (en_iyi:true):
→ Listedeki 1. mekandan başla, sırayla devam et
→ $sureDakika dakikaya kadar mümkün olan max mekanı ekle
→ ${hasOzelMekan ? '"$ozelMekan" mutlaka ekle' : ''}
→ ${yemekVar ? 'Yemeği $yemekZamaniStr' : ''}

Rota 2 (en_iyi:false):
→ Rota 1'deki mekanları KULLANMA
→ Listede Rota 1'de kullanılmayan mekanlardan başla
→ ${hasOzelMekan ? '"$ozelMekan" yine ekle' : ''}
→ Rota 1 ile aynı olmasın!

Rota 3 (en_iyi:false):
→ Rota 1 ve 2'de kullanılmayan mekanlardan seç
→ ${hasOzelMekan ? '"$ozelMekan" yine ekle' : ''}
→ Rota 1 ve 2 ile aynı olmasın!

KESİN KURALLAR:
✓ Koordinatları listeden AYNEN kopyala!
✓ Sadece listede olan mekanları kullan, UYDURMA!
✓ $sureDakika dakikayı GEÇME!
✓ ${kacinStr.isNotEmpty ? 'EKLEME: $kacinStr' : ''}
✓ 3 rota birbirinden farklı olacak!

SADECE JSON döndür:
{"rotalar":[
  {"baslik":"En Iyi Rota","sure":"X saat Y dakika","aciklama":"Turkce aciklama","en_iyi":true,
   "duraklar":[{"isim":"Mekan","konum":"lat,lng","sure":"45 dakika","tur":"kultur","ulasim":"driving"}]},
  {"baslik":"Rota 2","sure":"...","aciklama":"...","en_iyi":false,"duraklar":[...]},
  {"baslik":"Rota 3","sure":"...","aciklama":"...","en_iyi":false,"duraklar":[...]}
]}""");

    return buffer.toString();
  }

  Future<String> askToErzurumAI(
    String userMessage, {
    String travelMode = 'driving',
    String? havaDurumu,
    String? yemekTercih,
    String? yemekZamani,
    List<String> kacinilacaklar = const [],
    List<String> aktiviteler = const [],
    String ozelMekan = '',
    int sureDakika = 120,
  }) async {
    try {
      if (havaDurumu != null) setHavaDurumu(havaDurumu);
      print('🚀 Rota: ${sureDakika}dk, $travelMode');

      final paralel = await Future.wait([
        _verileriYukle().then((_) => null),
        _getUserLocation(),
        _getGroqKey(),
      ]);

      final userPos = paralel[1] as Position?;
      final groqKey = paralel[2] as String;
      final startLat = userPos?.latitude ?? 39.9042;
      final startLng = userPos?.longitude ?? 41.2677;
      final yemekVar = yemekTercih != null && yemekTercih != 'hayir';

      final ozelKoord = _ozelMekanKoordinat(ozelMekan);
      final merkezLat = ozelKoord?['lat'];
      final merkezLng = ozelKoord?['lng'];

      final refLat = merkezLat ?? startLat;
      final refLng = merkezLng ?? startLng;

      // Mekanları filtrele
      var kulturFiltre = List<Map<String, dynamic>>.from(_kulturCache!);

      // Kaçınılacakları filtrele
      kulturFiltre = kulturFiltre.where((p) {
        final kat = (p['category'] ?? '').toString().toLowerCase();
        if (kacinilacaklar.contains('dini') && kat == 'religious') return false;
        if (kacinilacaklar.contains('muze') && kat == 'museum') return false;
        if (kacinilacaklar.contains('doga_kacin') &&
            ['nature', 'sport'].contains(kat)) return false;
        if (kacinilacaklar.contains('alisveris_kacin') &&
            kat == 'shopping') return false;
        return true;
      }).toList();

      // Aktivite filtresi
      final hedefKat = <String>[];
      if (aktiviteler.contains('kultur')) {
        hedefKat.addAll(['culture', 'museum', 'religious']);
      }
      if (aktiviteler.contains('doga')) {
        hedefKat.addAll(['nature', 'sport']);
      }
      if (aktiviteler.contains('alisveris')) {
        hedefKat.add('shopping');
      }

      if (hedefKat.isNotEmpty) {
        final filtered = kulturFiltre.where((p) {
          final kat = (p['category'] ?? '').toString().toLowerCase();
          return hedefKat.contains(kat);
        }).toList();
        if (filtered.isNotEmpty) kulturFiltre = filtered;
      }

      // Hava filtresi
      if (_icMekanOncelikli) {
        final icFiltre = kulturFiltre.where((p) {
          final kat = (p['category'] ?? '').toString().toLowerCase();
          return ['museum', 'culture', 'religious'].contains(kat);
        }).toList();
        if (icFiltre.isNotEmpty) kulturFiltre = icFiltre;
      }

      // Özel mekan varsa skorla öne al
      if (ozelMekan.isNotEmpty) {
        kulturFiltre.sort((a, b) {
          final aIsim = (a['name'] ?? '').toString().toLowerCase();
          final bIsim = (b['name'] ?? '').toString().toLowerCase();
          final aMatch = aIsim.contains(ozelMekan.toLowerCase()) ? 0 : 1;
          final bMatch = bIsim.contains(ozelMekan.toLowerCase()) ? 0 : 1;
          return aMatch.compareTo(bMatch);
        });
      }

      // Nearest-neighbor ile sırala - BİZ yapıyoruz!
      final siraliKultur = _nearestNeighborSirala(
          kulturFiltre, refLat, refLng);

      print('📍 Nearest-neighbor sırası:');
      for (int i = 0; i < siraliKultur.length && i < 10; i++) {
        print('  ${i + 1}. ${siraliKultur[i]['name']} → ${siraliKultur[i]['_distFromPrev']}m');
      }

      // Yemek mekanları
      List<Map<String, dynamic>> siraliYemek = [];
      if (yemekVar) {
        var yemekFiltre = List<Map<String, dynamic>>.from(_yemekCache!);
        if (yemekTercih != 'fark etmez') {
          final filtered = yemekFiltre.where((p) {
            final name = (p['name'] ?? '').toString().toLowerCase();
            final cat = (p['category'] ?? '').toString().toLowerCase();
            return name.contains(yemekTercih!.toLowerCase()) ||
                cat.contains(yemekTercih.toLowerCase());
          }).toList();
          if (filtered.isNotEmpty) yemekFiltre = filtered;
        }
        // Yemeği nearest-neighbor ile sırala
        siraliYemek = _nearestNeighborSirala(yemekFiltre, refLat, refLng)
            .take(8)
            .toList();
      }

      final prompt = _buildPrompt(
        startLat: startLat,
        startLng: startLng,
        sureDakika: sureDakika,
        travelMode: travelMode,
        yemekTercih: yemekTercih,
        yemekZamani: yemekZamani,
        aktiviteler: aktiviteler,
        kacinilacaklar: kacinilacaklar,
        ozelMekan: ozelMekan,
        siraliKultur: siraliKultur,
        siraliYemek: siraliYemek,
        ozelMekanLat: merkezLat,
        ozelMekanLng: merkezLng,
      );

      print('📝 Prompt: ${prompt.length} karakter');

      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Sen deneyimli bir Erzurum sehir rehberi asistanisin. Kullanicinin kriterlerine gore en mantikli rotayi olusturursun. SADECE gecerli JSON dondur.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.1,
          'max_tokens': 2500,
          'response_format': {'type': 'json_object'},
        }),
      ).timeout(const Duration(seconds: 30));

      print('📡 HTTP: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        print('🤖 Groq: $content');

        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonStr = content.substring(jsonStart, jsonEnd + 1);
          final decoded = jsonDecode(jsonStr);
          if (decoded['rotalar'] != null) {
            print('✅ ${(decoded['rotalar'] as List).length} rota hazır');
            return jsonStr;
          }
        }
        return content;
      } else {
        print('❌ Hata: ${response.statusCode} - ${response.body}');
        return '{"hata": "API hatasi: ${response.statusCode}"}';
      }
    } catch (e) {
      print('💥 Hata: $e');
      return '{"hata": "Hata: $e"}';
    }
  }
}