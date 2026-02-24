import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Image.network(
                'https://developers.google.com/identity/images/g-logo.png',
                height: 22,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
              ),
        label: const Text(
          'Sign up with Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A2E),
          ),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
