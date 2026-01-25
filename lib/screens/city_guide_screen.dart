import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Bu ekran, Erzurum ile ilgili genel tanıtım metnini ve bir YouTube videosunu gösterir.

class CityGuideScreen extends StatefulWidget {
  const CityGuideScreen({super.key});

  @override
  State<CityGuideScreen> createState() => _CityGuideScreenState();
}

class _CityGuideScreenState extends State<CityGuideScreen> {
  // YouTube player controller'ı başlangıçta null olarak tanımlanır.
  late YoutubePlayerController _controller;
  bool _isPlayerInitialized = false;

  // Firestore'dan tek bir döküman çekmek için stream tanımlanır.
  Stream<QuerySnapshot> get _guideStream =>
      FirebaseFirestore.instance.collection('videos').limit(1).snapshots();

  @override
  void dispose() {
    // Kontrolcü başlatıldıysa, dispose edildiğinden emin olun.
    if (_isPlayerInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  // YouTube URL'sini alır ve oynatıcıyı başlatır.
  void _initializeYoutubePlayer(String youtubeUrl) {
    // YouTube URL'sinden video ID'sini çıkarır
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl);

    if (videoId != null && !_isPlayerInitialized) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          loop: true,
        ),
      );
      setState(() {
        _isPlayerInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // KRİTİK DÜZELTME: Scaffold'u tamamen opak siyah yapıyoruz. Bu, altındaki metinlerin sızmasını kesin olarak engeller.
    return Scaffold(
      backgroundColor: Colors.black, // Sızma sorununu çözmek için opak siyah
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Şehir Rehberi & Tanıtım"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _guideStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          // Dökümanı çekme (listeden ilk elemanı alıyoruz)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Şehir rehberi verisi bulunamadı. Lütfen Firestore\'a "videos" koleksiyonuna veri ekleyin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            );
          }

          // İlk dökümanı alıyoruz.
          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final title = data['title'] as String? ?? 'Erzurum Tanıtım';
          final description = data['video_text'] as String? ?? 'Şehir hakkında detaylı bilgi bulunmamaktadır.';
          final videoUrl = data['video_url'] as String? ?? '';

          // YouTube Oynatıcısını Başlatma
          if (videoUrl.isNotEmpty && !_isPlayerInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeYoutubePlayer(videoUrl);
            });
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. YouTube Oynatıcısı
                if (_isPlayerInitialized)
                  Container(
                    margin: const EdgeInsets.only(top: 80, bottom: 20),
                    child: YoutubePlayer(
                      controller: _controller,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Theme.of(context).primaryColor,
                      onReady: () {
                        print('YouTube Player Hazır');
                      },
                    ),
                  )
                else
                  // Eğer video URL'si yoksa veya player başlatılamadıysa
                  Container(
                    height: 250,
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 80, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.videoOff, color: Colors.white, size: 40),
                          SizedBox(height: 10),
                          Text(
                            "Video verisi bekleniyor/başlatılamadı.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 2. Tanıtım Metin Kartı (Artık altındaki metin sızmayacak)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // Opaklık 1.0 yaparak tam siyah yapıyoruz (zaten Scaffold siyah ama emin olmak için).
                      color: Colors.black.withOpacity(0.9), 
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 30),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}