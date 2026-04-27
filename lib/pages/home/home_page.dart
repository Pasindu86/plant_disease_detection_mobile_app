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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  Future<List<Map<String, dynamic>>>? _detectionsFuture;

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
          padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 16.0),
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
