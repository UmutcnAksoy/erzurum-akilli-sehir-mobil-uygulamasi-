import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class CityGuideScreen extends StatefulWidget {
  const CityGuideScreen({super.key});

  @override
  State<CityGuideScreen> createState() => _CityGuideScreenState();
}

class _CityGuideScreenState extends State<CityGuideScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  bool _videoHazir = false;
  bool _isPlaying = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  Future<void> _initVideo() async {
    _videoController =
        VideoPlayerController.asset('assets/videos/erzurum_tanitim.mp4');
    await _videoController.initialize();
    _videoController.setLooping(true);
    setState(() => _videoHazir = true);
  }

  void _togglePlay() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        _isPlaying = false;
      } else {
        _videoController.play();
        _isPlaying = true;
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Şehir Rehberi",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVideoSection(),
              _buildDescriptionSection(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      margin: const EdgeInsets.only(top: 90),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_videoHazir)
            AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            )
          else
            Container(
              height: 220,
              width: double.infinity,
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          if (_videoHazir)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
              ),
            ),

          if (_videoHazir)
            GestureDetector(
              onTap: _togglePlay,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(color: Colors.white54, width: 2),
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),

          if (_videoHazir)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _videoController,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        String title = 'Erzurum Tanıtım';
        String description =
            'Erzurum, Doğu Anadolu\'nun en büyük şehirlerinden biri olup tarihi ve kültürel zenginlikleriyle öne çıkmaktadır.';

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final data =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;
          title = data['title'] ?? title;
          description =
              data['video_text'] ?? data['description'] ?? description;
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_city,
                          color: Colors.white70, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Divider(color: Colors.white12),

                const SizedBox(height: 16),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _statChip(Icons.height, "2200m", "Rakım"),
                    _statChip(Icons.people, "800K+", "Nüfus"),
                    _statChip(Icons.history, "3000+", "Yıllık Tarih"),
                    _statChip(Icons.ac_unit, "-30°C", "En Soğuk"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white60, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}