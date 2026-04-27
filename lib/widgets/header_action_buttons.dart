import 'package:flutter/material.dart';
import '../pages/chat/chat_page.dart';
import '../pages/scan/scan_page.dart';

/// Reusable Ask & Scan action buttons for page headers.
/// Use this widget in any page's AppBar or header row.
class HeaderActionButtons extends StatelessWidget {
  const HeaderActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AI Assistant button
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatPage()),
            );
          },
          icon: const Icon(Icons.forum_rounded, size: 18),
          label: const Text('Ask', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50), // Updated to match app color
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }
}
