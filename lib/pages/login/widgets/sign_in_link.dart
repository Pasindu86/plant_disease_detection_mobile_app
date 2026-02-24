import 'package:flutter/material.dart';

class SignInLink extends StatelessWidget {
  final VoidCallback onTap;

  const SignInLink({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already a member? ',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
