import 'dart:ui'; // ImageFilter için gerekli
import 'package:flutter/material.dart';

class WeatherSummaryCard extends StatelessWidget {
  const WeatherSummaryCard({super.key});

  final String _currentTemp = "-5°C";
  final String _condition = "Yoğun Kar Yağışı";
  final IconData _icon = Icons.ac_unit;

  @override
  Widget build(BuildContext context) {
    // ClipRRect: Bulanıklık efektinin köşelerden taşmamasını sağlar
    return ClipRRect(
      borderRadius: BorderRadius.circular(20), // Modern yuvarlak köşeler
      child: BackdropFilter(
        // BULANIKLIK AYARI (Buzlu cam etkisi burada oluşur)
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            // Yarı şeffaf renk (Siyahın %40'ı)
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            // İnce beyaz çerçeve (Premium hissi verir)
            border: Border.all(
              color: Colors.white.withOpacity(0.2), 
              width: 1.5
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _condition,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 20, 
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        "Palandöken, Erzurum",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  // İkonu biraz daha belirgin yapalım
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_icon, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currentTemp,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}