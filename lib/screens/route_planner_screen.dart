import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  // Varsayılan Değerler
  double _hourValue = 3.0;
  String _transport = 'Araç ile';
  
  // İlgi Alanları
  bool _wantFood = true;
  bool _wantCulture = true;
  bool _wantNature = false;
  
  // Sonuçları tutacak değişkenler
  String _generatedRoute = ""; 
  bool _isLoading = false;

  void _createRoute() async {
    setState(() {
      _isLoading = true;
      _generatedRoute = "";
    });

    // Simülasyon: Sanki AI düşünüyormuş gibi 2 saniye bekle
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _generatedRoute = "✅ Rota Oluşturuldu! (Az önce indirdiğin beyin dosyasını telefona atınca burası gerçek cevap verecek.)";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Arkaplanı ana iskeletten alacak
      appBar: AppBar(
        title: const Text("Akıllı Rota Oluştur", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. SÜRE SEÇİMİ ---
            _buildSectionTitle("Ne kadar vaktin var?"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(LucideIcons.clock, color: Colors.white70),
                      Text("${_hourValue.toInt()} Saat", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _hourValue,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.grey[800],
                    onChanged: (val) => setState(() => _hourValue = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- 2. ULAŞIM ARACI ---
            _buildSectionTitle("Nasıl gideceksin?"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildTransportOption("Araç ile", LucideIcons.car)),
                const SizedBox(width: 10),
                Expanded(child: _buildTransportOption("Yürüyerek", LucideIcons.footprints)),
              ],
            ),

            const SizedBox(height: 25),

            // --- 3. İLGİ ALANLARI ---
            _buildSectionTitle("Nelerden hoşlanırsın?"),
            const SizedBox(height: 10),
            _buildCheckbox("Cağ Kebabı & Yemek", _wantFood, (val) => setState(() => _wantFood = val!)),
            _buildCheckbox("Tarih & Kültür", _wantCulture, (val) => setState(() => _wantCulture = val!)),
            _buildCheckbox("Doğa & Temiz Hava", _wantNature, (val) => setState(() => _wantNature = val!)),

            const SizedBox(height: 30),

            // --- BUTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.sparkles, color: Colors.white),
                          SizedBox(width: 10),
                          Text("ROTAYI OLUŞTUR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
             // --- SONUÇ ALANI ---
            if (_generatedRoute.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Text(_generatedRoute, style: const TextStyle(color: Colors.white)),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: const TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildTransportOption(String title, IconData icon) {
    bool isSelected = _transport == title;
    return GestureDetector(
      onTap: () => setState(() => _transport = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.black54,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        value: value,
        activeColor: Colors.blueAccent,
        checkColor: Colors.white,
        onChanged: onChanged,
      ),
    );
  }
}