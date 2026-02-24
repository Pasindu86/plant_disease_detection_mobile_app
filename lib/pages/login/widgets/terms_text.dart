import 'package:flutter/material.dart';

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          children: [
            TextSpan(text: 'By signing up, you agree to our '),
            TextSpan(
              text: 'Terms',
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Color(0xFF6B7280),
              ),
            ),
            TextSpan(text: ' & '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Color(0xFF6B7280),
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
