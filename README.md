#  Erzurum Atlası - Akıllı Şehir Rehberi

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Llama 3.3](https://img.shields.io/badge/AI-Llama%203.3%2070B-orange?style=for-the-badge)

**Erzurum Atlası**, Erzurum şehrini ziyaret eden turistlere ve şehir sakinlerine yapay zeka destekli, kişiselleştirilmiş gezi rotaları sunan bir Android mobil uygulamasıdır. Bu proje, **TÜBİTAK 2209-A** Üniversite Öğrencileri Araştırma Projeleri Destekleme Programı kapsamında geliştirilmiştir.

---

##  Proje Hakkında
Uygulama; kullanıcının anlık konumu, sahip olduğu süre, aktivite tercihleri, yemek zevki ve kısıtlamaları doğrultusunda en mantıklı gezi rotasını otomatik olarak oluşturur. Geleneksel rehberlerden farkı, statik listeler yerine dinamik ve optimize edilmiş rotalar sunmasıdır.

###  Proje Ekibi
* **Ekip Yöneticisi ve Proje Yürütücüsü:** [Umut Can AKSOY](https://github.com/UmutcnAksoy)
* **Ekip Üyesi:** [Sevginur ÖZER](https://github.com/SevginurOzer)
* **Ekip Üyesi:** [Abdussamed ÇİÇEK](https://github.com/sameddcicekk)
* **Danışman:** Metin İPKİN
* **Kurum:** Atatürk Üniversitesi - Yönetim Bilişim Sistemleri

---

##  Kullanılan Teknolojiler
* **Frontend:** Flutter (Dart)
* **Backend & Veritabanı:** Firebase Firestore
* **Yapay Zeka Motoru:** Groq API - Llama 3.3 70B Versatile
* **Konum & Harita:** Google Maps API, Geolocator
* **Hava Durumu:** OpenWeatherMap API
* **Yardımcı Araçlar:** Firebase Remote Config (Güvenli API Yönetimi), Flutter TTS (Sesli Rehber)
* **Tasarım:** Flex Color Scheme, Google Fonts

> **Neden Groq / Llama 3.3?**
> Yapılan testlerde GPT-4'ün maliyeti, Gemini'ın entegrasyon kısıtları ve Phi-4'ün Türkçe yetersizliği nedeniyle; yüksek hızı (2-3 sn yanıt süresi), ücretsiz erişimi ve güçlü Türkçe JSON çıktısı verme yeteneği sayesinde **Llama 3.3** tercih edilmiştir.

---

##  Öne Çıkan Özellikler

### Yapay Zeka Destekli Rota Planlama
Kullanıcıdan alınan 7 farklı kriter (süre, ulaşım, aktivite, yemek türü vb.) doğrultusunda Groq API aracılığıyla 3 farklı alternatif rota üretilir.

###  Çok Kriterli Skor Sistemi & Algoritma
Projede geleneksel Dijkstra yerine çok kriterli bir yaklaşım kullanılmıştır:
- **Skor Formülü:** `10000 / mesafe` temel alınarak popülerlik ve kullanıcı tercihlerine göre ağırlıklandırılır.
- **Nearest-Neighbor:** Kullanıcı konumundan başlayarak her adımda süre kısıtına uygun en optimize bir sonraki durak seçilir.
- **Mekan Gruplama:** Mekanlar yürüme mesafesi (0-500m), kısa mesafe (500m-1.5km) ve araç mesafesi (+1.5km) olarak kategorize edilir.

###  Hava Durumu Duyarlılığı
Hava durumuna göre rota dinamik olarak güncellenir. Kötü hava koşullarında sistem otomatik olarak kapalı alanlara (Müze, Medrese, Cami vb.) öncelik verir.

###  Sesli Rehber (Maskot)
Uygulama içindeki maskot karakter, kullanıcı bir mekana 150 metre yaklaştığında otomatik bildirim gönderir ve **Flutter TTS** kullanarak mekan hakkında sesli bilgi sunar.

---

## Proje Yapısı
```text
lib/
├── models/          # Veri modelleri (route_model.dart)
├── services/        # AI ve Firebase servisleri (ai_service.dart)
├── screens/         # Uygulama ekranları (Ana sayfa, Planlayıcı, Maskot vb.)
├── widgets/         # Tekrar kullanılabilir arayüz bileşenleri
└── main.dart        # Uygulama giriş noktası
