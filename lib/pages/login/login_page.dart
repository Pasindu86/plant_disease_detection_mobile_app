import 'package:flutter/material.dart';
import 'package:plant_disease_detection_mobile_app/pages/email_signup/email_signup_page.dart';
import 'package:plant_disease_detection_mobile_app/pages/email_signin/email_signin_page.dart';
import 'package:plant_disease_detection_mobile_app/pages/home/home_page.dart';
import 'package:plant_disease_detection_mobile_app/services/auth_service.dart';
import 'widgets/login_header.dart';
import 'widgets/google_sign_in_button.dart';
import 'widgets/or_divider.dart';
import 'widgets/email_sign_up_button.dart';
import 'widgets/sign_in_link.dart';
import 'widgets/terms_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── Header Image with Logo ─────────────────────
              const LoginHeader(),

              const SizedBox(height: 32),

              // ─── Title ──────────────────────────────────────
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Start detecting diseases and protecting your\nharvest today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ─── Google Sign-In Button ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GoogleSignInButton(
                  isLoading: _isLoading,
                  onPressed: _handleGoogleSignIn,
                ),
              ),

              const SizedBox(height: 20),

              // ─── OR divider ─────────────────────────────────
              const OrDivider(),

              const SizedBox(height: 20),

              // ─── Sign Up with Email Button ──────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: EmailSignUpButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EmailSignUpPage()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ─── Already a member? Sign In ──────────────────
              SignInLink(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EmailSignInPage()),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ─── Terms & Privacy ────────────────────────────
              const TermsText(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
