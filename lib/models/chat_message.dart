class ChatMessage {
  final String text;
  final bool isUser; // true ise kullanıcı, false ise AI

  ChatMessage({required this.text, required this.isUser});
}