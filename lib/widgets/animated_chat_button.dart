import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../globals.dart';
import '../pages/chat/chat_page.dart';

class AnimatedChatButton extends StatefulWidget {
  const AnimatedChatButton({super.key});

  @override
  State<AnimatedChatButton> createState() => _AnimatedChatButtonState();
}

class _AnimatedChatButtonState extends State<AnimatedChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Hide if not logged in, or if locally hidden
        if (!snapshot.hasData || !_isVisible) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<bool>(
          valueListenable: showAiAssistant,
          builder: (context, showAi, child) {
            if (!showAi) return const SizedBox.shrink();

            return Positioned(
              bottom: 120, // Just above the bottom nav bar (typically 110px)
              right: 24,
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FloatingActionButton(
                heroTag: 'global_chat_fab',
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 8,
                onPressed: () async {
                  setState(() => _isVisible = false);

                  // Use the global navigator key to push the chat page
                  await globalNavigatorKey.currentState?.push(
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/chat'),
                      builder: (_) => const ChatPage(),
                    ),
                  );

                  // When it pops back, show the button again
                  if (mounted) {
                    setState(() => _isVisible = true);
                  }
                },
                // Reverted to a built-in flutter icon until the physical image file is downloaded and placed in assets/images/
                child: const Icon(
                  Icons.auto_awesome, // A great sparkling AI icon to represent the bot!
                  size: 32,
                  color: Colors.white,
                ),
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
