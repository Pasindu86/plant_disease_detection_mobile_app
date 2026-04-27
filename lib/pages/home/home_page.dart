import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plant_disease_detection_mobile_app/pages/scan/scan_page.dart';
import 'package:plant_disease_detection_mobile_app/pages/profile/user_profile_page.dart';
import 'package:plant_disease_detection_mobile_app/pages/chat/chat_page.dart';
import 'package:plant_disease_detection_mobile_app/widgets/custom_bottom_navbar.dart';
import 'package:plant_disease_detection_mobile_app/widgets/header_action_buttons.dart';
import 'package:plant_disease_detection_mobile_app/widgets/weather_quick_action_card.dart';
import 'package:plant_disease_detection_mobile_app/globals.dart';
import 'package:plant_disease_detection_mobile_app/services/disease_detection_service.dart';
import 'package:plant_disease_detection_mobile_app/services/plant_classifier_service.dart';
import 'package:plant_disease_detection_mobile_app/pages/scan/scan_history_page.dart';
import 'package:plant_disease_detection_mobile_app/pages/scan/result_page.dart';
import 'package:plant_disease_detection_mobile_app/pages/home/care_treatments_page.dart';
import 'package:plant_disease_detection_mobile_app/pages/login/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  Future<List<Map<String, dynamic>>>? _detectionsFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _refreshDetections();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAiAssistant.value = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      globalRouteObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    globalRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and the current route shows up.
    _refreshDetections();
  }

  void _refreshDetections() {
    setState(() {
      _detectionsFuture = DiseaseDetectionService().getUserDetections();
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

  Future<void> _handleSignOut(BuildContext context) async {
    Navigator.pop(context); // Close drawer first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildDrawer(BuildContext context, String firstName, String email) {
    final initials = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'F';

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1EAC50), Color(0xFF178740)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Menu Items ───────────────────────────────────────────
          _drawerTile(
            context,
            icon: Icons.person_outline,
            label: 'My Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfilePage()),
              );
            },
          ),
          _drawerTile(
            context,
            icon: Icons.history,
            label: 'Scan History',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanHistoryPage()),
              ).then((_) {
                if (mounted) _refreshDetections();
              });
            },
          ),

          const Spacer(),

          // ── Logout ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(color: Colors.grey.shade200),
          ),
          _drawerTile(
            context,
            icon: Icons.logout_outlined,
            label: 'Sign Out',
            iconColor: Colors.red,
            labelColor: Colors.red,
            onTap: () => _handleSignOut(context),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Plant Care v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
    Color labelColor = Colors.black87,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor == Colors.red
              ? Colors.red.withOpacity(0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: labelColor,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final greeting = _getGreeting();
    final firstName = _getFirstName(user);

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context, firstName, user?.email ?? ''),
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
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
                  const HeaderActionButtons(),
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
                      ).then((_) {
                        if (mounted) _refreshDetections();
                      });
                    },
                    child: _buildQuickActionCard(
                      title: 'Identify',
                      subtitle: 'Disease',
                      icon: Icons.camera_alt_outlined,
                      bgColor: const Color(0xFFE5F9E9), // Light Green
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CareTreatmentsPage(),
                        ),
                      );
                    },
                    child: _buildQuickActionCard(
                      title: 'Care',
                      subtitle: 'Treatments',
                      icon: Icons.medical_services_outlined,
                      bgColor: const Color(0xFFF0F5FF), // Light Blue
                    ),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScanHistoryPage(),
                        ),
                      ).then((_) {
                        if (mounted) _refreshDetections();
                      });
                    },
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

              // Disease Alerts Future
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _detectionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Could not load alerts.',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(color: Colors.black38),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }

                  final detections = snapshot.data ?? [];

                  // Filter for only unhealthy plants (diseases) and take the last 5
                  final recentDetections = detections
                      .where((d) => d['isHealthy'] == false)
                      .take(5)
                      .toList();

                  if (recentDetections.isEmpty) {
                    return Container(
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
                    );
                  }

                  return SizedBox(
                    height: 180, // Set height for horizontally scrollable cards
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentDetections.length,
                      itemBuilder: (context, index) {
                        final detection = recentDetections[index];
                        final diseaseName =
                            detection['diseaseName'] ?? 'Unknown';
                        final confidence =
                            (detection['confidence'] as num?)?.toDouble() ??
                            0.0;
                        final isHealthy = detection['isHealthy'] == true;
                        final imagePath = detection['imagePath'] as String?;

                        Widget imageWidget = Container(
                          color: isHealthy
                              ? const Color(0xFFE5F9E9)
                              : const Color(0xFFFFEBEE),
                          child: Center(
                            child: Icon(
                              isHealthy ? Icons.check_circle : Icons.warning,
                              color: isHealthy
                                  ? const Color(0xFF1EAC50)
                                  : Colors.red,
                              size: 40,
                            ),
                          ),
                        );

                        if (imagePath != null && imagePath.isNotEmpty) {
                          imageWidget = Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                imageWidget,
                          );
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResultPage(
                                  imagePath: imagePath ?? '',
                                  results: [
                                    ClassificationResult(
                                      label: diseaseName,
                                      confidence: confidence,
                                    ),
                                  ],
                                  isHistory: true,
                                ),
                              ),
                            ).then((_) {
                              if (mounted) setState(() {});
                            });
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image section
                                  Expanded(flex: 3, child: imageWidget),
                                  // Details section
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            diseaseName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                isHealthy
                                                    ? Icons.check_circle
                                                    : Icons.warning,
                                                color: isHealthy
                                                    ? const Color(0xFF1EAC50)
                                                    : Colors.red,
                                                size: 12,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${(confidence * 100).toStringAsFixed(0)}% Match',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),



              const SizedBox(height: 80), // Padding for bottom nav bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
