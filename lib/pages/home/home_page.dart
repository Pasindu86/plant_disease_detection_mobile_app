import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_disease_detection_mobile_app/pages/scan/scan_page.dart';
import 'package:plant_disease_detection_mobile_app/pages/profile/user_profile_page.dart';
import 'package:plant_disease_detection_mobile_app/pages/chat/chat_page.dart';
import 'package:plant_disease_detection_mobile_app/widgets/custom_bottom_navbar.dart';
import 'package:plant_disease_detection_mobile_app/widgets/weather_quick_action_card.dart';
import 'package:plant_disease_detection_mobile_app/globals.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAiAssistant.value = true;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  String _getFirstName(User? user) {
    if (user == null) return 'Farmer';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      // Split by space and return the first name
      return user.displayName!.split(' ')[0];
    }
    return 'Farmer';
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final greeting = _getGreeting();
    final firstName = _getFirstName(user);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Profile Routing
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserProfilePage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.menu, color: Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        firstName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanPage()),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1EAC50),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Quick Actions Title
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanPage()),
                      );
                    },
                    child: _buildQuickActionCard(
                      title: 'Identify',
                      subtitle: 'Disease',
                      icon: Icons.camera_alt_outlined,
                      bgColor: const Color(0xFFE5F9E9), // Light Green
                    ),
                  ),
                  _buildQuickActionCard(
                    title: 'Care',
                    subtitle: 'Treatments',
                    icon: Icons.medical_services_outlined,
                    bgColor: const Color(0xFFF0F5FF), // Light Blue
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatPage()),
                      );
                    },
                    child: _buildQuickActionCard(
                      title: 'Ask',
                      subtitle: 'Experts',
                      icon: Icons.chat_bubble_outline,
                      bgColor: const Color(0xFFFFF5EE), // Light Peach
                    ),
                  ),
                  const WeatherQuickActionCard(),
                ],
              ),

              const SizedBox(height: 32),

              // Disease Alerts Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Disease Alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF1EAC50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Disease Alerts Empty State
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No active alerts at the moment.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // My Plants Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Plants',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {},
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // My Plants Empty State
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Tap the + button to add your first plant.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              ),

              const SizedBox(height: 80), // Padding for bottom nav bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        onScanTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ScanPage(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
      ),
    );
  }
}
