import 'package:flutter/material.dart';
import '../../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    final response = await _chatService.sendMessage(text);

    setState(() {
      _messages.add({"role": "bot", "text": response});
      _isLoading = false;
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Plant Assistant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message["role"] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF1EAC50) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 20),
                        ),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: Text(
                        message["text"] ?? "",
                        style: TextStyle(
                          fontSize: 15.0,
                          color: isUser ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                   height: 24,
                   width: 24,
                   child: CircularProgressIndicator(
                     color: Color(0xFF1EAC50),
                     strokeWidth: 2.5,
                   ),
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 20.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ask about plant care...',
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.black87),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1EAC50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
