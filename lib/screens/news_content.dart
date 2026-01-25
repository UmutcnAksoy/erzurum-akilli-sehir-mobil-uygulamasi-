import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart'; // Tema uyumu için

// ----------------------------------------------------------------------
// 1. MODELLER (Backend'den gelen JSON yapısına uygun)
// ----------------------------------------------------------------------

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String imageUrl;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      // Backend'deki anahtarlar: 'baslik', 'aciklama', 'link', 'gorsel'
      title: json['baslik'] ?? 'Başlık Yok',
      description: json['aciklama'] ?? json['kaynak'] ?? 'Detaylar haberin devamında...',
      url: json['link'] ?? '#',
      imageUrl: json['gorsel'] ?? 'https://placehold.co/400x300/1E293B/ffffff?text=Erzurum',
    );
  }
}

// ----------------------------------------------------------------------
// 2. EKRAN (WIDGET)
// ----------------------------------------------------------------------

class NewsContent extends StatefulWidget {
  const NewsContent({super.key});

  @override
  State<NewsContent> createState() => _NewsContentState();
}

class _NewsContentState extends State<NewsContent> {
  // Backend adresi (Emülatör için 10.0.2.2)
  final String backendUrl = "http://10.0.2.2:8000/haberler";
  
  Future<List<NewsArticle>>? _newsData;

  @override
  void initState() {
    super.initState();
    _newsData = fetchNews();
  }

  // ----------------------------------------------------------------------
  // URL AÇMA FONKSİYONU (Android 11+ Uyumlu)
  // ----------------------------------------------------------------------
  Future<void> _launchURL(String url) async {
    if (url == '#' || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu haberin linki bulunmuyor.')),
        );
      }
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      // 'externalApplication' modu, linki uygulamanın içinde değil, Chrome/Tarayıcıda açar.
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Link açılamadı: $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    }
  }

  // ----------------------------------------------------------------------
  // VERİ ÇEKME FONKSİYONU (DÜZELTİLMİŞ)
  // ----------------------------------------------------------------------
  Future<List<NewsArticle>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(backendUrl));

      if (response.statusCode == 200) {
        // UTF-8 decoding yaparak Türkçe karakter sorununu çözeriz
        // Backend direkt liste [ ... ] döndüğü için List<dynamic> olarak alıyoruz.
        final List<dynamic> articlesJson = jsonDecode(utf8.decode(response.bodyBytes));

        if (articlesJson.isEmpty) {
          // Backend çalışıyor ama liste boşsa, frontend tarafında yedek gösterelim
          return _getFrontendDummyNews();
        }

        // Gelen listeyi NewsArticle objelerine çevir
        return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        print('Backend Hatası: ${response.statusCode}');
        return _getFrontendDummyNews(); // Hata varsa yedek göster
      }
    } catch (e) {
      print('Bağlantı Hatası: $e');
      // Hiç bağlanamazsa (Backend kapalıysa) yine yedek göster ki ekran boş kalmasın
      return _getFrontendDummyNews();
    }
  }

  // Frontend tarafındaki acil durum yedek verileri
  List<NewsArticle> _getFrontendDummyNews() {
    return [
      NewsArticle(
        title: "Erzurum'da Kış Turizmi Rekor Kırıyor",
        description: "Palandöken kayak merkezi bu yıl turist akınına uğradı.",
        url: "https://www.google.com/search?q=Erzurum+Palandöken",
        imageUrl: "https://placehold.co/400x300/2a64c4/ffffff?text=PALANDOKEN",
      ),
      NewsArticle(
        title: "Tarihi Yakutiye Medresesi Restore Ediliyor",
        description: "Kültür ve Turizm Bakanlığı yeni projeyi duyurdu.",
        url: "https://www.google.com/search?q=Yakutiye+Medresesi",
        imageUrl: "https://placehold.co/400x300/4a7065/ffffff?text=TARIH",
      ),
      NewsArticle(
        title: "Erzurumspor Süper Lig Yolunda",
        description: "Mavi beyazlı ekip son maçında galip geldi.",
        url: "https://www.google.com/search?q=Erzurumspor",
        imageUrl: "https://placehold.co/400x300/0000FF/ffffff?text=SPOR",
      ),
    ];
  }

  // ----------------------------------------------------------------------
  // ARAYÜZ (UI)
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Tema renkleri
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.white.withOpacity(0.1) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : Colors.black54;

    // Çentik ve bar boşlukları
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 10;
    final double bottomPadding = kBottomNavigationBarHeight + 20;

    return FutureBuilder<List<NewsArticle>>(
      future: _newsData,
      builder: (context, snapshot) {
        // 1. Yükleniyor Durumu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        } 
        
        // 2. Hata veya Veri Yok Durumu (Yedek fonksiyonumuz olduğu için buraya nadiren düşer)
        else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "Haberler yüklenemedi.",
              style: TextStyle(color: textColor),
            ),
          );
        }

        final news = snapshot.data!;

        // 3. Liste Görünümü
        return ListView.builder(
          padding: EdgeInsets.only(
            top: topPadding,
            bottom: bottomPadding,
            left: 16.0,
            right: 16.0,
          ),
          itemCount: news.length,
          itemBuilder: (context, index) {
            final article = news[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                color: cardColor,
                elevation: 4, // Hafif gölge
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _launchURL(article.url),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Görsel
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          article.imageUrl,
                          height: 180, // Görseli biraz daha büyük yaptım
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(Icons.image_not_supported, size: 50, color: Colors.white24),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Yazılar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Habere Git >",
                                  style: TextStyle(
                                    color: Colors.blueAccent[100],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}