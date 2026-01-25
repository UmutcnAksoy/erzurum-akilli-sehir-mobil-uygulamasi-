import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // JSON işlemleri için

class AIService {
  
  // Bu fonksiyonu çağırınca konsola EĞİTİM VERİSİ basacak
  Future<void> exportDataForTraining() async {
    print("⏳ Veriler Firebase'den çekiliyor ve eğitim setine dönüştürülüyor...");

    List<Map<String, String>> trainingData = [];

    // --- 1. ÜNİVERSİTELERİ ÇEK ---
    try {
      var uniSnapshot = await FirebaseFirestore.instance.collection('universities').get();
      
      for (var doc in uniSnapshot.docs) {
        var data = doc.data();
        String name = data['name'] ?? 'Bilinmeyen Üniversite';
        String desc = data['description'] ?? 'Açıklama yok.';
        String address = data['address_detail'] ?? 'Adres yok.';
        
        // Varyasyon A: Genel Bilgi
        trainingData.add({
          "instruction": "$name hakkında bilgi verir misin?",
          "input": "",
          "output": "$name, Erzurum'da bulunan köklü bir eğitim kurumudur. $address adresinde bulunur. Detaylı bilgi: $desc"
        });

        // Varyasyon B: Konum Sorusu
        trainingData.add({
          "instruction": "$name nerede?",
          "input": "",
          "output": "$name şu adreste yer almaktadır: $address."
        });
      }
    } catch (e) {
      print("❌ Üniversite verisi hatası: $e");
    }

    // --- 2. KAFE VE RESTORANLARI ÇEK ---
    try {
      var foodSnapshot = await FirebaseFirestore.instance.collection('food_places').get();
      
      for (var doc in foodSnapshot.docs) {
        var data = doc.data();
        String name = data['name'] ?? 'İsimsiz Mekan';
        String address = data['address'] ?? data['address_detail'] ?? 'Adres belirtilmemiş';
        var ratingVal = data['rating'];
        String rating = ratingVal != null ? ratingVal.toString() : 'Puanı yok';
        String category = "Yemek"; 

        // Varyasyon A: Tavsiye
        trainingData.add({
          "instruction": "Erzurum'da güzel bir $category mekanı önerir misin?",
          "input": "",
          "output": "Kesinlikle! $name mekanını deneyebilirsin. Kullanıcılardan ortalama $rating puan almış. Adresi şöyle: $address"
        });

        // Varyasyon B: Spesifik Mekan Bilgisi
        trainingData.add({
          "instruction": "$name nasıl bir yer?",
          "input": "",
          "output": "$name, Erzurum'da popüler bir mekandır. Puan ortalaması $rating civarındadır ve $address konumunda hizmet verir."
        });
      }
    } catch (e) {
      print("❌ Kafe verisi hatası: $e");
    }

    // --- SONUÇ: JSONL FORMATINDA YAZDIR ---
    print("\n⬇️ AŞAĞIDAKİ SATIRLARI KOPYALA (Eğitim Verisi Başlangıcı) ⬇️\n");
    
    for (var item in trainingData) {
      // JSONL formatı
      print(jsonEncode(item));
    }

    print("\n⬆️ YUKARIDAKİ SATIRLARI KOPYALA (Eğitim Verisi Bitişi) ⬆️\n");
    print("✅ Toplam ${trainingData.length} adet eğitim satırı oluşturuldu.");
  }
}