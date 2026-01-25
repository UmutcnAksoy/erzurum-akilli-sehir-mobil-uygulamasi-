import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Timer için
import 'package:intl/intl.dart'; // Tarih ve saat formatı için

// Backend'den gelen hava durumu verilerini tutmak için model sınıfı
class WeatherData {
  final String sehir;
  final String sicaklik;
  final String durum;
  final String ikon;
  // Backend bu verileri gönderse bile UI'da kullanmayacağız,
  // ancak modelde tutmak JSON parse hatasını önler.
  final String hissedilen;
  final String nem;

  WeatherData({
    required this.sehir,
    required this.sicaklik,
    required this.durum,
    required this.ikon,
    required this.hissedilen,
    required this.nem,
  });

  // JSON'dan WeatherData nesnesi oluşturur
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      sehir: json['sehir'] ?? 'Bilinmiyor',
      sicaklik: json['sicaklik'] ?? '--',
      durum: json['durum'] ?? 'Veri Yok',
      ikon: json['ikon'] ?? 'cloud',
      hissedilen: json['hissedilen'] ?? '--',
      nem: json['nem'] ?? '--',
    );
  }
}

// Hava durumu ikonlarını Flutter Material ikonlarına eşleştirme fonksiyonu
IconData getWeatherIcon(String iconName) {
  switch (iconName) {
    case 'sun':
      return Icons.wb_sunny; // Güneşli
    case 'moon':
      return Icons.mode_night; // Ay
    case 'cloud_sun':
      return Icons.cloud_queue; // Güneşli ve Bulutlu
    case 'cloud_moon':
      return Icons.cloud_queue; // Ay ve Bulutlu
    case 'cloud':
      return Icons.cloud; // Bulutlu
    case 'rain':
      return Icons.umbrella; // Yağmurlu
    case 'storm':
      return Icons.thunderstorm; // Fırtınalı
    case 'snow':
      return Icons.ac_unit; // Karlı
    case 'fog':
      return Icons.foggy; // Sisli
    default:
      return Icons.help_outline;
  }
}

class WeatherSummaryCard extends StatefulWidget {
  const WeatherSummaryCard({super.key});

  @override
  State<WeatherSummaryCard> createState() => _WeatherSummaryCardState();
}

class _WeatherSummaryCardState extends State<WeatherSummaryCard> {
  // Backend sunucusunun adresi
  // Android Emülatör: 10.0.2.2, Gerçek Cihaz: Bilgisayarın IP'si (örn: 192.168.1.35)
  final String backendUrl = "http://10.0.2.2:8000/hava-durumu";

  Future<WeatherData>? _weatherData;
  Timer? _weatherTimer;
  Timer? _clockTimer; // YENİ: Saati saniye saniye güncellemek için
  
  String _currentTime = DateFormat('HH:mm').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    
    // 1. Hava Durumu Verisi: Uygulama açıldığında çek ve periyodik olarak güncelle (5 dakikada bir)
    _weatherData = fetchWeather();
    _weatherTimer = Timer.periodic(const Duration(minutes: 5), (Timer t) {
      if (mounted) {
        setState(() {
          _weatherData = fetchWeather();
        });
      }
    });

    // 2. YENİ EKLENDİ: Saati saniye saniye akıtmak için (1 saniyede bir güncelle)
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat('HH:mm').format(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _weatherTimer?.cancel(); // Hava durumu zamanlayıcısını temizle
    _clockTimer?.cancel();   // YENİ: Saat zamanlayıcısını temizle
    super.dispose();
  }

  Future<WeatherData> fetchWeather() async {
    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        return WeatherData.fromJson(jsonDecode(response.body));
      } else {
        return WeatherData(
          sehir: "Erzurum",
          sicaklik: '---',
          durum: 'Veri Hatası',
          ikon: 'cloud',
          hissedilen: '---',
          nem: '---',
        );
      }
    } catch (e) {
      return WeatherData(
        sehir: "Erzurum",
        sicaklik: '---',
        durum: 'Bağlantı Sorunu',
        ikon: 'cloud',
        hissedilen: '---',
        nem: '---',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData>(
      future: _weatherData,
      builder: (context, snapshot) {
        // Veri beklerken yükleniyor ekranı
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        } 
        
        // Hata oluştuysa veya veri geldiyse
        final data = snapshot.data ?? 
            WeatherData(
                sehir: 'Erzurum', 
                sicaklik: '--', 
                durum: 'Hata', 
                ikon: 'cloud', 
                hissedilen: '--',
                nem: '--',
            );
        
        // Ana kartın buzlu cam tasarımı
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0), // İç boşluk
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // Hafif şeffaf beyaz arka plan
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.5), // Buzlu cam çerçevesi
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Satır: Şehir ve Saat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${data.sehir}, Merkez',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Sağ Üst: Güncel Saat (Artık saniye saniye akacak)
                  Text(
                    _currentTime,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 25), 

              // Orta Satır: Sıcaklık, Durum ve İkon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sol: Sıcaklık ve Durum
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data.sicaklik}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64, // Oldukça büyük ve okunaklı
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(color: Colors.black38, blurRadius: 4),
                          ],
                        ),
                      ),
                      Text(
                        data.durum,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 20, // Yazı boyutunu artırdım
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  // Sağ: İkon
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      getWeatherIcon(data.ikon),
                      size: 80, // İkonu büyüttüm
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              // Nem ve Hissedilen satırları kaldırılmıştır.
            ],
          ),
        );
      },
    );
  }

  // Yükleniyor durumunu gösteren basit bir kart
  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      height: 200, 
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              "Hava Durumu Yükleniyor...",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}