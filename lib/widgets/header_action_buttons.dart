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
          icon: const Icon(Icons.forum_rounded, size: 14),
          label: const Text('Ask', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1EAC50),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Scan button
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanPage()),
            );
          },
          icon: const Icon(Icons.document_scanner_rounded, size: 14),
          label: const Text('Scan', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1EAC50),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }
}
