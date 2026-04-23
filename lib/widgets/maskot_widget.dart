import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MaskotWidget extends StatefulWidget {
  final String? mekanAdi;
  final String? mekanAciklama;
  final bool autoSpeak;

  const MaskotWidget({
    super.key,
    this.mekanAdi,
    this.mekanAciklama,
    this.autoSpeak = false,
  });

  @override
  State<MaskotWidget> createState() => _MaskotWidgetState();
}

class _MaskotWidgetState extends State<MaskotWidget>
    with TickerProviderStateMixin {
  late FlutterTts _tts;
  bool _isConusuyor = false;
  bool _isLoading = false;

  // Bounce animasyonu
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Ses dalgası animasyonu
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  // Göz kırpma animasyonu
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initAnimations();

    if (widget.autoSpeak && widget.mekanAciklama != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _konusMekanHakkinda();
      });
    }
  }

  void _initAnimations() {
    // Bounce - konuşurken yukarı aşağı
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Ses dalgası
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _waveAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Göz kırpma
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Periyodik göz kırpma
    _startBlinking();
  }

  void _startBlinking() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        await _blinkController.forward();
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) _blinkController.reverse();
      }
    }
  }

  void _initTts() async {
    _tts = FlutterTts();
    await _tts.setLanguage("tr-TR");
    await _tts.setSpeechRate(0.85);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);

    _tts.setStartHandler(() {
      if (mounted) {
        setState(() => _isConusuyor = true);
        _bounceController.repeat(reverse: true);
        _waveController.repeat(reverse: true);
      }
    });

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isConusuyor = false);
        _bounceController.stop();
        _bounceController.reset();
        _waveController.stop();
        _waveController.reset();
      }
    });

    _tts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isConusuyor = false;
          _isLoading = false;
        });
        _bounceController.stop();
        _waveController.stop();
      }
    });
  }

  Future<void> _konusMekanHakkinda() async {
    if (widget.mekanAciklama == null) return;

    setState(() => _isLoading = true);

    await _tts.stop();

    final mesinText = widget.mekanAdi != null
        ? "${widget.mekanAdi}. ${widget.mekanAciklama}"
        : widget.mekanAciklama!;

    setState(() => _isLoading = false);
    await _tts.speak(mesinText);
  }

  Future<void> _durdur() async {
    await _tts.stop();
    if (mounted) {
      setState(() => _isConusuyor = false);
      _bounceController.stop();
      _bounceController.reset();
      _waveController.stop();
      _waveController.reset();
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _bounceController.dispose();
    _waveController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // MASKOT + ANİMASYONLAR
        GestureDetector(
          onTap: _isConusuyor ? _durdur : _konusMekanHakkinda,
          child: SizedBox(
            width: 180,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ses dalgası halkaları (konuşurken)
                if (_isConusuyor)
                  AnimatedBuilder(
                    animation: _waveAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildWaveRing(
                              _waveAnimation.value * 90, 0.3),
                          _buildWaveRing(
                              _waveAnimation.value * 70, 0.2),
                          _buildWaveRing(
                              _waveAnimation.value * 50, 0.1),
                        ],
                      );
                    },
                  ),

                // Maskot görseli (bounce animasyonu)
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _bounceAnimation.value),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/images/maskot.png',
                    width: 160,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Maskot adı ve durum
        Text(
          "Dadaş",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // Durum metni
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _isLoading
                ? "Hazırlanıyor..."
                : _isConusuyor
                    ? "Konuşuyor... (durdurmak için dokun)"
                    : widget.mekanAdi != null
                        ? "\"${widget.mekanAdi}\" hakkında bilgi almak için dokun"
                        : "Merhaba! Ben Dadaş, rehberinizim!",
            key: ValueKey(_isConusuyor),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        // Buton
        if (widget.mekanAdi != null)
          GestureDetector(
            onTap: _isConusuyor ? _durdur : _konusMekanHakkinda,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _isConusuyor
                    ? Colors.red.withOpacity(0.3)
                    : Colors.cyanAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isConusuyor
                      ? Colors.red.withOpacity(0.6)
                      : Colors.cyanAccent.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isConusuyor ? Icons.stop : Icons.volume_up,
                    color: _isConusuyor ? Colors.red : Colors.cyanAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isConusuyor ? "Durdur" : "Anlat",
                    style: TextStyle(
                      color: _isConusuyor ? Colors.red : Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWaveRing(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(opacity),
          width: 2,
        ),
      ),
    );
  }
}