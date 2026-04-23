import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class WeatherData {
  final String sehir;
  final double sicaklik;
  final String durum;
  final String ikon;
  final int nem;
  final double ruzgar;

  WeatherData({
    required this.sehir,
    required this.sicaklik,
    required this.durum,
    required this.ikon,
    required this.nem,
    required this.ruzgar,
  });
}

class WeatherSummaryCard extends StatefulWidget {
  const WeatherSummaryCard({super.key});

  @override
  State<WeatherSummaryCard> createState() => _WeatherSummaryCardState();
}

class _WeatherSummaryCardState extends State<WeatherSummaryCard> {
  WeatherData? _weatherData;
  bool _isLoading = true;
  bool _isError = false;
  Timer? _weatherTimer;
  Timer? _clockTimer;
  String _currentTime = DateFormat('HH:mm').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _fetchWeather();

    _weatherTimer = Timer.periodic(const Duration(minutes: 10), (t) {
      if (mounted) _fetchWeather();
    });

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat('HH:mm').format(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _weatherTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<String> _getApiKey() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.fetchAndActivate();
      final key = remoteConfig.getString('openweather_api_key');
      if (key.isNotEmpty) return key;
    } catch (e) {
      print('❌ Remote Config hatası: $e');
    }
    // Fallback
    return '37d51f7bbe3e032bc37108058022fb35';
  }

  Future<void> _fetchWeather() async {
    try {
      setState(() => _isLoading = true);

      final apiKey = await _getApiKey();
      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=39.9042&lon=41.2677&appid=$apiKey&units=metric&lang=tr";

      print('🌤️ Hava durumu isteği gönderiliyor...');
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      print('📡 HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        final weatherId = json['weather'][0]['id'] as int;
        final isDay = _isGunduz(json['sys']['sunrise'], json['sys']['sunset']);

        setState(() {
          _weatherData = WeatherData(
            sehir: "Erzurum",
            sicaklik: (json['main']['temp'] as num).toDouble(),
            durum: _turkceHavaDurumu(weatherId),
            ikon: _getIcon(weatherId, isDay),
            nem: json['main']['humidity'] as int,
            ruzgar: (json['wind']['speed'] as num).toDouble(),
          );
          _isLoading = false;
          _isError = false;
        });
      } else {
        print('❌ HTTP Hata: ${response.statusCode}');
        setState(() { _isLoading = false; _isError = true; });
      }
    } catch (e) {
      print('❌ Hava durumu hatası: $e');
      setState(() { _isLoading = false; _isError = true; });
    }
  }

  bool _isGunduz(int sunrise, int sunset) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= sunrise && now <= sunset;
  }

  String _turkceHavaDurumu(int id) {
    if (id >= 200 && id < 300) return 'Fırtınalı';
    if (id >= 300 && id < 400) return 'Çiseleyen';
    if (id >= 500 && id < 600) return 'Yağmurlu';
    if (id >= 600 && id < 700) return 'Karlı';
    if (id >= 700 && id < 800) return 'Sisli';
    if (id == 800) return 'Açık';
    if (id == 801) return 'Az Bulutlu';
    if (id == 802) return 'Parçalı Bulutlu';
    if (id >= 803) return 'Bulutlu';
    return 'Bilinmiyor';
  }

  String _getIcon(int id, bool isDay) {
    if (id >= 200 && id < 300) return 'storm';
    if (id >= 300 && id < 600) return 'rain';
    if (id >= 600 && id < 700) return 'snow';
    if (id >= 700 && id < 800) return 'fog';
    if (id == 800) return isDay ? 'sun' : 'moon';
    if (id == 801 || id == 802) return 'cloud_sun';
    return 'cloud';
  }

  IconData _getWeatherIcon(String iconName) {
    switch (iconName) {
      case 'sun': return Icons.wb_sunny_rounded;
      case 'moon': return Icons.mode_night_rounded;
      case 'cloud_sun': return Icons.wb_cloudy_rounded;
      case 'cloud': return Icons.cloud_rounded;
      case 'rain': return Icons.beach_access_rounded;
      case 'storm': return Icons.thunderstorm_rounded;
      case 'snow': return Icons.ac_unit_rounded;
      case 'fog': return Icons.cloud_circle_rounded;
      default: return Icons.wb_cloudy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Erzurum, Merkez",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _currentTime,
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoading
                            ? "--°C"
                            : _isError
                                ? "--°C"
                                : "${_weatherData!.sicaklik.toStringAsFixed(0)}°C",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 62,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _isLoading
                            ? "Yükleniyor..."
                            : _isError
                                ? "Bağlantı Sorunu"
                                : _weatherData!.durum,
                        style: TextStyle(
                          color: _isError ? Colors.redAccent : Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Icon(
                          _getWeatherIcon(
                              _isError ? 'cloud' : (_weatherData?.ikon ?? 'cloud')),
                          size: 80,
                          color: Colors.white.withOpacity(0.9),
                        ),
                ],
              ),
              if (!_isLoading && !_isError && _weatherData != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoChip(Icons.water_drop, "${_weatherData!.nem}%", "Nem"),
                    _infoChip(Icons.air,
                        "${_weatherData!.ruzgar.toStringAsFixed(1)} m/s", "Rüzgar"),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white60, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}