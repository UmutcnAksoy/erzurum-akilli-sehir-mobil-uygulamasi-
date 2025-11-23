// lib/screens/route_content.dart (NİHAİ KOD - DİREKT SOHBET EKRANI)

import 'package:flutter/material.dart';

class RouteContent extends StatefulWidget {
  const RouteContent({super.key});

  @override
  State<RouteContent> createState() => _RouteContentState();
}

class _RouteContentState extends State<RouteContent> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Mesajları ve kimden geldiğini tutar

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

  void _handleSendPressed(String text) {
    if (text.isEmpty) return;
    _textController.clear();
    
    setState(() {
      _messages.add({"message": text, "isUser": true}); // Kullanıcı mesajını ekle
    });

    // TODO: AI Backend'e API çağrısı burada yapılacak
    // Simülasyon: AI'dan sahte bir cevap al
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add({
          "message": "İsteğini aldım: '$text'. Hemen senin için en iyi rotayı hazırlıyorum...",
          "isUser": false,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ekranın üst ve alt boşluklarını hesapla
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    final double bottomNavHeight = kBottomNavigationBarHeight;

    // Bu ekran artık bir 'Column' (dikey)
    // 1. (Expanded) Mesaj listesi
    // 2. (Container) Yazı yazma çubuğu
    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight + appBarHeight), // Sadece üstten boşluk
      child: Column(
        children: [
          // --- 1. MESAJ LİSTESİ ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              reverse: true, // Listeyi aşağıdan yukarıya doğru tutar
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Listeyi tersten okuduğumuz için
                final messageData = _messages[_messages.length - 1 - index];
                return _ChatMessageBubble(
                  message: messageData["message"],
                  isUserMessage: messageData["isUser"],
                );
              },
            ),
          ),
          
          // --- 2. YAZI YAZMA ÇUBUĞU ---
          _buildTextInputArea(context, bottomNavHeight),
        ],
      ),
    );
  }

  // Alttaki mesaj yazma çubuğu (Arkaplan fotoğrafına uygun)
  Widget _buildTextInputArea(BuildContext context, double bottomNavHeight) {
    return Container(
      // Padding, alt menünün ve telefonun alt çubuğunun üstünde kalması için
      padding: EdgeInsets.only(
        bottom: bottomNavHeight + MediaQuery.of(context).padding.bottom + 10,
        left: 16,
        right: 16,
        top: 10,
      ),
      // Bu container'ın kendisi şeffaf
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white), // Yazı rengi beyaz
              decoration: InputDecoration(
                hintText: "Bir rota iste...",
                hintStyle: const TextStyle(color: Colors.white70), // Hint (ipucu) beyaz
                filled: true,
                // Yarı-şeffaf siyah dolgu
                fillColor: Colors.black.withOpacity(0.5), 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none, // Kenarlık yok
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: _handleSendPressed, // Enter'a basınca gönder
            ),
          ),
          const SizedBox(width: 8),
          // Gönder Butonu
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white, // Beyaz buton
            child: const Icon(Icons.send, color: Colors.black), // Siyah ikon
            onPressed: () => _handleSendPressed(_textController.text),
          ),
        ],
      ),
    );
  }
}

// Sohbet Baloncuğu (Arkaplan fotoğrafına uygun)
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
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          // Kullanıcı: Yarı-şeffaf beyaz
          // AI: Yarı-şeffaf siyah (Hava durumu kartı gibi)
          color: isUserMessage
              ? Colors.white.withOpacity(0.9)
              : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(15),
          border: !isUserMessage
              ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
              : null,
        ),
        child: Text(
          message,
          style: TextStyle(
            // Yazı renkleri arkaplanla kontrast olmalı
            color: isUserMessage ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}