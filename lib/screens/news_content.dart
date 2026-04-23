import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String source;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'Başlık Yok',
      description: json['description'] ?? 'Detaylar haberin devamında...',
      url: json['url'] ?? '#',
      imageUrl: json['urlToImage'] ?? '',
      source: json['source']?['name'] ?? 'Haber',
    );
  }
}

class NewsContent extends StatefulWidget {
  const NewsContent({super.key});

  @override
  State<NewsContent> createState() => _NewsContentState();
}

class _NewsContentState extends State<NewsContent> {
  Future<List<NewsArticle>>? _newsData;

  @override
  void initState() {
    super.initState();
    _newsData = fetchNews();
  }

  Future<String> _getApiKey() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.fetchAndActivate();
      final key = remoteConfig.getString('news_api_key');
      if (key.isNotEmpty) return key;
    } catch (e) {
      print('❌ Remote Config hatası: $e');
    }
    return '77c434cf9caf4b11bbb1199112c8471c';
  }

  Future<void> _launchURL(String url) async {
    if (url == '#' || url.isEmpty) return;
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Açılamadı';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Haber linki açılamadı.')));
      }
    }
  }

  Future<List<NewsArticle>> fetchNews() async {
    try {
      final apiKey = await _getApiKey();

      // Erzurum'a özel haberler - birden fazla kaynak dene
      final urls = [
        // Türkçe Erzurum haberleri
        'https://newsapi.org/v2/everything?q=Erzurum&language=tr&sortBy=publishedAt&pageSize=20&apiKey=$apiKey',
        // İngilizce Erzurum haberleri (Türkçe yetmezse)
        'https://newsapi.org/v2/everything?q=Erzurum+Turkey&sortBy=publishedAt&pageSize=20&apiKey=$apiKey',
      ];

      for (final url in urls) {
        print('📰 Haberler çekiliyor: $url');
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 10));

        print('📡 HTTP Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final articles = data['articles'] as List<dynamic>;

          final filtered = articles
              .where((a) =>
                  a['title'] != null &&
                  a['title'] != '[Removed]' &&
                  a['url'] != null &&
                  // Sadece Erzurum ile ilgili haberleri filtrele
                  (a['title'].toString().toLowerCase().contains('erzurum') ||
                   a['description']?.toString().toLowerCase().contains('erzurum') == true))
              .map((a) => NewsArticle.fromJson(a))
              .toList();

          if (filtered.isNotEmpty) return filtered;
        }
      }

      return _getDummyNews();
    } catch (e) {
      print('❌ Haber bağlantı hatası: $e');
      return _getDummyNews();
    }
  }

  List<NewsArticle> _getDummyNews() {
    return [
      NewsArticle(
        title: "Palandöken'de Kayak Sezonu Heyecanı",
        description: "Erzurum'da kar kalınlığı istenen seviyeye ulaştı.",
        url: "https://www.google.com/search?q=Erzurum+Palandoken",
        imageUrl: "",
        source: "Erzurum Haber",
      ),
      NewsArticle(
        title: "Erzurum Akıllı Şehir Uygulaması",
        description: "Uygulama üzerinden tüm ulaşım hatlarına ulaşabilirsiniz.",
        url: "#",
        imageUrl: "",
        source: "Sistem",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsArticle>>(
      future: _newsData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        final news = snapshot.data ?? [];

        if (news.isEmpty) {
          return const Center(
            child: Text(
              "Haber bulunamadı",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 100),
          itemCount: news.length,
          itemBuilder: (context, index) {
            final article = news[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _launchURL(article.url),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                      child: article.imageUrl.isNotEmpty
                          ? Image.network(
                              article.imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.newspaper,
                                  color: Colors.blueAccent, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                article.source,
                                style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (article.description.isNotEmpty)
                            Text(
                              article.description,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 10),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Devamını oku",
                                style: TextStyle(
                                    color: Colors.blueAccent, fontSize: 12),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  color: Colors.blueAccent, size: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper, color: Colors.white24, size: 48),
          SizedBox(height: 8),
          Text("Erzurum Haberleri",
              style: TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }
}