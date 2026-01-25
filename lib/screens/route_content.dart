import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RouteContent extends StatefulWidget {
  const RouteContent({super.key});

  @override
  State<RouteContent> createState() => _RouteContentState();
}

class _RouteContentState extends State<RouteContent> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Mesajları tutan liste
  bool _isLoading = false; // Yükleniyor durumu

  // Backend Adresi (Emülatör için 10.0.2.2, Gerçek Cihaz için bilgisayarının IP'si)
  final String backendUrl = "http://10.0.2.2:8000/chat"; 

  @override
  void initState() {
    super.initState();
    // Ekran açıldığında AI'dan ilk karşılama mesajını ekle
    setState(() {
      _messages.add({
        "message": "Merhaba! Ben Erzurum AI Rota Asistanı. Sana nasıl bir plan oluşturabilirim?\n(Örn: 2 saatim var, tarihi yerleri gezmek istiyorum)",
        "isUser": false,
      });
    });
  }

  Future<void> _handleSendPressed(String text) async {
    if (text.isEmpty) return;
    _textController.clear();
    
    // 1. Kullanıcı mesajını ekrana ekle
    setState(() {
      _messages.add({"message": text, "isUser": true});
      _isLoading = true; // Yükleniyor göstergesini aç
    });

    try {
      // 2. Backend'e istek at
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mesaj": text}),
      );

      if (response.statusCode == 200) {
        // 3. Başarılı cevap geldiyse işle
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // Türkçe karakter düzeltmesi
        final String aiResponse = data['cevap'];

        if (mounted) {
          setState(() {
            _messages.add({
              "message": aiResponse,
              "isUser": false,
            });
          });
        }
      } else {
        // Sunucu hatası
        if (mounted) {
          setState(() {
            _messages.add({
              "message": "Sunucuya ulaşılamadı. Hata kodu: ${response.statusCode}",
              "isUser": false,
            });
          });
        }
      }
    } catch (e) {
      // Bağlantı hatası
      if (mounted) {
        setState(() {
          _messages.add({
            "message": "Bağlantı hatası: $e. Backend çalışıyor mu?",
            "isUser": false,
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Yükleniyor göstergesini kapat
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    final double bottomNavHeight = kBottomNavigationBarHeight;

    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight + appBarHeight), 
      child: Column(
        children: [
          // --- MESAJ LİSTESİ ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              reverse: true, // Listeyi aşağıdan yukarıya doğru tutar
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final messageData = _messages[_messages.length - 1 - index];
                return _ChatMessageBubble(
                  message: messageData["message"],
                  isUserMessage: messageData["isUser"],
                );
              },
            ),
          ),
          
          // --- YÜKLENİYOR GÖSTERGESİ ---
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // --- YAZI YAZMA ÇUBUĞU ---
          _buildTextInputArea(context, bottomNavHeight),
        ],
      ),
    );
  }

  Widget _buildTextInputArea(BuildContext context, double bottomNavHeight) {
    return Container(
      padding: EdgeInsets.only(
        bottom: bottomNavHeight + MediaQuery.of(context).padding.bottom + 10,
        left: 16,
        right: 16,
        top: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Bir rota iste...",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black.withOpacity(0.6), 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: _handleSendPressed,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            child: const Icon(Icons.send, color: Colors.black),
            onPressed: () => _handleSendPressed(_textController.text),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isUserMessage;

  const _ChatMessageBubble({
    required this.message,
    required this.isUserMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUserMessage
              ? Colors.white.withOpacity(0.9)
              : Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUserMessage ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isUserMessage ? const Radius.circular(0) : const Radius.circular(20),
          ),
          border: !isUserMessage
              ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
              : null,
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUserMessage ? Colors.black : Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}