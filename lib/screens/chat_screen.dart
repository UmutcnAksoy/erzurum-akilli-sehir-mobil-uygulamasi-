import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/route_model.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  final AiService _aiService = AiService();
  bool _isLoading = false;

  List<RouteModel>? _parseRoutes(String response) {
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) return null;
      final jsonStr = response.substring(jsonStart, jsonEnd + 1);
      final decoded = jsonDecode(jsonStr);
      if (decoded['rotalar'] != null) {
        return (decoded['rotalar'] as List)
            .map((r) => RouteModel.fromJson(r))
            .toList();
      }
    } catch (e) {}
    return null;
  }

  String _buildMapsUrl(RouteModel route) {
    if (route.duraklar.isEmpty) return '';
    final duraklar = route.duraklar;
    final origin = duraklar.first.konum;
    final destination = duraklar.last.konum;
    final waypoints = duraklar.length > 2
        ? duraklar.sublist(1, duraklar.length - 1).map((d) => d.konum).join('|')
        : '';
    String url = 'https://www.google.com/maps/dir/?api=1'
        '&origin=$origin'
        '&destination=$destination'
        '&travelmode=walking';
    if (waypoints.isNotEmpty) url += '&waypoints=$waypoints';
    return url;
  }

  void _handleSend() async {
    if (_controller.text.trim().isEmpty) return;
    final userText = _controller.text.trim();
    setState(() {
      _messages.add({'type': 'user', 'text': userText});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final aiResponse = await _aiService.askToErzurumAI(userText);
    final routes = _parseRoutes(aiResponse);

    setState(() {
      if (routes != null && routes.isNotEmpty) {
        _messages.add({'type': 'routes', 'routes': routes});
      } else {
        _messages.add({'type': 'ai', 'text': aiResponse});
      }
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  IconData _stopIcon(String tur) {
    switch (tur) {
      case 'yemek': return Icons.restaurant;
      case 'kultur': return Icons.museum;
      case 'universite': return Icons.school;
      case 'otel': return Icons.hotel;
      case 'saglik': return Icons.local_hospital;
      default: return Icons.location_on;
    }
  }

  Color _stopColor(String tur) {
    switch (tur) {
      case 'yemek': return Colors.orange;
      case 'kultur': return Colors.purple;
      case 'universite': return Colors.blue;
      case 'otel': return Colors.teal;
      case 'saglik': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildRouteCard(RouteModel route) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: route.enIyi ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: route.enIyi
            ? const BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (route.enIyi)
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                if (route.enIyi) const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    route.baslik,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: route.enIyi ? Colors.amber[800] : Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    route.sure,
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(route.aciklama,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 12),
            ...route.duraklar.asMap().entries.map((entry) {
              final i = entry.key;
              final durak = entry.value;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: _stopColor(durak.tur),
                        child: Icon(_stopIcon(durak.tur),
                            size: 14, color: Colors.white),
                      ),
                      if (i < route.duraklar.length - 1)
                        Container(width: 2, height: 28, color: Colors.grey[300]),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(durak.isim,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(durak.sure,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final url = _buildMapsUrl(route);
                  if (url.isNotEmpty) {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  }
                },
                icon: const Icon(Icons.map, size: 18),
                label: const Text("Google Maps'te Aç"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Akıllı Rota Planlayıcı"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.blue[50],
            child: Text(
              '💡 "3 saatim var, kültürel yerleri gezmek istiyorum" gibi yaz',
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

                if (msg['type'] == 'user') {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(msg['text'],
                          style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }

                if (msg['type'] == 'routes') {
                  final routes = msg['routes'] as List<RouteModel>;
                  final sorted = [...routes]
                    ..sort((a, b) => b.enIyi ? 1 : -1);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, top: 8, bottom: 4),
                        child: Text(
                          "İşte senin için rota önerilerim:",
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                      ...sorted.map((r) => _buildRouteCard(r)).toList(),
                    ],
                  );
                }

                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(msg['text']),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Text("Rotalar hesaplanıyor...",
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4)
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ne yapmak istiyorsun?",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue[600],
                  child: IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.white, size: 20),
                    onPressed: _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}