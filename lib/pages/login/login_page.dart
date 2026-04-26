import 'package:flutter/material.dart';
import 'package:plant_disease_detection_mobile_app/pages/email_signup/email_signup_page.dart';
import 'package:plant_disease_detection_mobile_app/pages/email_signin/email_signin_page.dart';
import 'package:plant_disease_detection_mobile_app/pages/onboarding/onboarding_page.dart';
import 'package:plant_disease_detection_mobile_app/services/auth_service.dart';
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
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
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
    final size = MediaQuery.of(context).size;
    final topSectionHeight = size.height * 0.35; // Top portion 35% of height

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ─── Top Background Image ─────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topSectionHeight + 40, // Extend behind the white card a bit
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/UI_interface.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.green.shade800),
                ),
                // Gradient overlay to darken image for text visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                // Logo and Text overlay
                Positioned(
                  bottom: 60, // Above the white card overlap
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Transform.scale(
                              scale: 1.6, // Zooms in on the image to reduce white space
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Plant Care',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'AI-powered care for your crops',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // ─── Bottom White Card ────────────────────────────
          Positioned(
            top: topSectionHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 32, bottom: 24),
                  child: Column(
                    children: [
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

                      const SizedBox(height: 24),

                      // ─── OR divider ─────────────────────────────────
                      const OrDivider(),

                      const SizedBox(height: 24),

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

                      const SizedBox(height: 40),

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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
