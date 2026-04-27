import 'package:flutter/material.dart';
import '../home/home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Color primaryGreen = const Color(0xFF1EAC50);

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Identify Diseases Instantly",
      "subtitle": "Use our AI to detect pests and diseases from a simple photo. Keep your peppers perfect.",
      "image": "assets/images/onboarding1.png"
    },
    {
      "title": "Smart Care Reminders",
      "subtitle": "Get automated schedules for watering, fertilizing, and pesticide application based on your plant's needs.",
      "image": "assets/images/onboarding2.png"
    },
    {
      "title": "Learn & Share",
      "subtitle": "Access a community of chilli enthusiasts and read articles on best farming practices.",
      "image": "assets/images/onboarding3.png"
    },
    {
      "title": "Community Marketplace",
      "subtitle": "Buy and sell fresh produce, quality seeds, and farming supplies directly with other farmers.",
      "image": "assets/images/onboarding4.png"
    },
  ];

  Future<void> _completeOnboarding() async {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 250,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryGreen.withOpacity(0.08),
                                  ),
                                ),
                                Image.asset(
                                  _onboardingData[index]["image"]!,
                                  fit: BoxFit.contain,
                                  height: 280,
                                  errorBuilder: (context, error, stackTrace) => 
                                    Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.image, size: 80, color: Colors.grey[400]),
                                    ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              Text(
                                _onboardingData[index]["title"]!,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _onboardingData[index]["subtitle"]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 10,
                        width: _currentPage == index ? 24 : 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? primaryGreen
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 18,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _onboardingData.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_currentPage < _onboardingData.length - 1) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ],
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
}
