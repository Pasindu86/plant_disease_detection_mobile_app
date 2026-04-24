import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  ChatService() {
    var apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      apiKey = 'dummy_api_key_for_testing'; // Provide a fallback so the app does not crash
    }

    _model = GenerativeModel(model: 'gemini-3-flash-preview', apiKey: apiKey);
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'dummy_api_key_for_testing') {
      return 'Error: GEMINI_API_KEY not set in assets/env/app.env. Please add it to use the chat assistant.';
    }
    
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'I could not understand that.';
    } catch (e) {
      return 'Error: Could not process the message. $e';
    }
  }
}
