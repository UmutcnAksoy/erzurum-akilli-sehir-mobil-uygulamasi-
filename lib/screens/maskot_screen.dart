import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';

class MaskotScreen extends StatefulWidget {
  final String? baslangicMekan; // Rotadan gelince bu mekan otomatik anlatılır

  const MaskotScreen({super.key, this.baslangicMekan});

  @override
  State<MaskotScreen> createState() => _MaskotScreenState();
}

class _MaskotScreenState extends State<MaskotScreen> {
  late FlutterTts _tts;
  bool _isConusuyor = false;
  List<Map<String, dynamic>> _mekanlar = [];
  Map<String, dynamic>? _seciliMekan;
  bool _yukleniyor = true;
  bool _menuAcik = false;

  late VideoPlayerController _videoController;
  bool _videoHazir = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _initTts();
    _mekanYukle();
  }

  Future<void> _initVideo() async {
    _videoController =
        VideoPlayerController.asset('assets/videos/maskot.mp4');
    await _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.setVolume(0);
    await _videoController.seekTo(Duration.zero);
    _videoController.pause();
    setState(() => _videoHazir = true);
  }

  void _initTts() async {
    _tts = FlutterTts();
    await _tts.setLanguage("tr-TR");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    try {
      final voices = await _tts.getVoices;
      if (voices != null) {
        final voiceList = voices as List;
        final erkekSes = voiceList.firstWhere(
          (v) =>
              v['locale']?.toString().toLowerCase().contains('tr') == true &&
              (v['name']?.toString().toLowerCase().contains('male') == true ||
                  v['name']?.toString().toLowerCase().contains('erkek') == true),
          orElse: () => null,
        );
        final turkceSes = voiceList.firstWhere(
          (v) => v['locale']?.toString().toLowerCase().contains('tr') == true,
          orElse: () => null,
        );
        final secilecekSes = erkekSes ?? turkceSes;
        if (secilecekSes != null) {
          await _tts.setVoice({
            'name': secilecekSes['name'],
            'locale': secilecekSes['locale'],
          });
        }
      }
    } catch (e) {
      print('❌ Ses hatası: $e');
    }

    _tts.setStartHandler(() {
      if (!mounted) return;
      setState(() => _isConusuyor = true);
      _videoController.play();
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _isConusuyor = false);
      _videoController.pause();
      _videoController.seekTo(Duration.zero);
    });

    _tts.setErrorHandler((msg) {
      if (!mounted) return;
      setState(() => _isConusuyor = false);
      _videoController.pause();
      _videoController.seekTo(Duration.zero);
    });
  }

  Future<void> _mekanYukle() async {
    try {
      Position? userPos;
      try {
        userPos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 8));
        final isEmulator = userPos.latitude > 36 &&
            userPos.latitude < 38 &&
            userPos.longitude < 0;
        if (isEmulator) userPos = null;
      } catch (e) {
        userPos = null;
      }

      final snapshot =
          await FirebaseFirestore.instance.collection('city_guide').get();

      List<Map<String, dynamic>> mekanlar = snapshot.docs.map((doc) {
        final data = doc.data();
        double dist = 99999;
        if (userPos != null && data['location'] is GeoPoint) {
          final loc = data['location'] as GeoPoint;
          dist = Geolocator.distanceBetween(userPos!.latitude,
              userPos.longitude, loc.latitude, loc.longitude);
        }
        return {...data, 'id': doc.id, '_distance': dist};
      }).toList();

      mekanlar.sort((a, b) =>
          (a['_distance'] as double).compareTo(b['_distance'] as double));

      setState(() {
        _mekanlar = mekanlar;
        _yukleniyor = false;
      });

      // Eğer rotadan gelindiyse o mekanı bul ve anlat
      if (widget.baslangicMekan != null) {
        final hedefMekan = mekanlar.firstWhere(
          (m) =>
              (m['name'] ?? m['id'])
                  .toString()
                  .toLowerCase()
                  .contains(widget.baslangicMekan!.toLowerCase()) ||
              widget.baslangicMekan!
                  .toLowerCase()
                  .contains((m['name'] ?? m['id']).toString().toLowerCase()),
          orElse: () => mekanlar.isNotEmpty ? mekanlar.first : {},
        );

        if (hedefMekan.isNotEmpty) {
          setState(() => _seciliMekan = hedefMekan);
          await Future.delayed(const Duration(milliseconds: 800));
          _mekanAnlat(hedefMekan);
        }
      } else {
        // Normal açılışta en yakın mekanı anlat
        setState(() =>
            _seciliMekan = mekanlar.isNotEmpty ? mekanlar.first : null);
        if (_seciliMekan != null) {
          await Future.delayed(const Duration(milliseconds: 1200));
          _mekanAnlat(_seciliMekan!);
        }
      }
    } catch (e) {
      setState(() => _yukleniyor = false);
    }
  }

  Future<void> _mekanAnlat(Map<String, dynamic> mekan) async {
    await _tts.stop();
    setState(() {
      _seciliMekan = mekan;
      _menuAcik = false;
    });
    final mekanAdi = mekan['name'] ?? mekan['id'] ?? '';
    final aciklama =
        mekan['description'] ?? 'Bu mekan hakkinda bilgi bulunmuyor.';
    await _tts.speak("$mekanAdi. $aciklama");
  }

  Future<void> _durdur() async {
    await _tts.stop();
    if (!mounted) return;
    setState(() => _isConusuyor = false);
    _videoController.pause();
    _videoController.seekTo(Duration.zero);
  }

  @override
  void dispose() {
    _tts.stop();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // TAM EKRAN VİDEO
          if (_videoHazir)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Üst gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // Alt gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),

          // İÇERİK
          SafeArea(
            child: Column(
              children: [
                // BAŞLIK
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                      ),
                      const Text(
                        "Sesli Rehberim",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Rotadan gelindiyse badge göster
                      if (widget.baslangicMekan != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.cyanAccent.withOpacity(0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.cyanAccent, size: 12),
                              SizedBox(width: 4),
                              Text(
                                "Rotadan",
                                style: TextStyle(
                                    color: Colors.cyanAccent, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),

                // ALT KISIM
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Konuşma kartı
                      if (_seciliMekan != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isConusuyor
                                  ? Colors.cyanAccent.withOpacity(0.6)
                                  : Colors.white24,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (_isConusuyor) ...[
                                _sesNoktaAnim(),
                                const SizedBox(width: 8),
                              ] else ...[
                                const Icon(Icons.record_voice_over,
                                    color: Colors.white54, size: 18),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  _isConusuyor
                                      ? "${_seciliMekan!['name'] ?? ''} anlatiliyor..."
                                      : _seciliMekan!['name'] ?? '',
                                  style: TextStyle(
                                    color: _isConusuyor
                                        ? Colors.cyanAccent
                                        : Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _isConusuyor
                                    ? _durdur
                                    : () => _mekanAnlat(_seciliMekan!),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _isConusuyor
                                        ? Colors.red.withOpacity(0.25)
                                        : Colors.cyanAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _isConusuyor
                                          ? Colors.red
                                          : Colors.cyanAccent,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isConusuyor
                                            ? Icons.stop
                                            : Icons.volume_up,
                                        color: _isConusuyor
                                            ? Colors.red
                                            : Colors.cyanAccent,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isConusuyor ? "Dur" : "Anlat",
                                        style: TextStyle(
                                          color: _isConusuyor
                                              ? Colors.red
                                              : Colors.cyanAccent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 10),

                      // AÇILIR MENÜ
                      GestureDetector(
                        onTap: () =>
                            setState(() => _menuAcik = !_menuAcik),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.map,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "Gezilecek Yerler",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Icon(
                                _menuAcik
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_up,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_menuAcik)
                        Container(
                          width: double.infinity,
                          constraints:
                              const BoxConstraints(maxHeight: 260),
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.88),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: _yukleniyor
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(
                                        color: Colors.cyanAccent),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6),
                                  itemCount: _mekanlar.length,
                                  itemBuilder: (context, index) {
                                    final mekan = _mekanlar[index];
                                    final isSecili =
                                        _seciliMekan?['id'] == mekan['id'];
                                    final dist =
                                        mekan['_distance'] as double;
                                    final distStr = dist < 99999
                                        ? dist < 1000
                                            ? "${dist.toInt()}m"
                                            : "${(dist / 1000).toStringAsFixed(1)}km"
                                        : '';

                                    return GestureDetector(
                                      onTap: () => _mekanAnlat(mekan),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSecili
                                              ? Colors.cyanAccent
                                                  .withOpacity(0.1)
                                              : Colors.transparent,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.white
                                                  .withOpacity(0.05),
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isSecili && _isConusuyor
                                                  ? Icons.volume_up
                                                  : Icons.place,
                                              color: isSecili
                                                  ? Colors.cyanAccent
                                                  : Colors.white38,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    mekan['name'] ??
                                                        mekan['id'],
                                                    style: TextStyle(
                                                      color: isSecili
                                                          ? Colors.white
                                                          : Colors.white70,
                                                      fontWeight: isSecili
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  if (distStr.isNotEmpty)
                                                    Text(
                                                      "$distStr uzaklikta",
                                                      style: const TextStyle(
                                                          color: Colors.white38,
                                                          fontSize: 11),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              isSecili && _isConusuyor
                                                  ? Icons.equalizer
                                                  : Icons.play_circle_outline,
                                              color: isSecili
                                                  ? Colors.cyanAccent
                                                  : Colors.white24,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sesNoktaAnim() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 1.0),
          duration: Duration(milliseconds: 300 + i * 150),
          builder: (context, value, _) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 4,
              height: 4 + (8 * value),
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          },
          onEnd: () => setState(() {}),
        );
      }),
    );
  }
}