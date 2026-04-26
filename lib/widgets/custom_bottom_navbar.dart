import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pages/home/home_page.dart';
import '../pages/marketplace/marketplace_page.dart';
import '../pages/garden/garden_page.dart' as plant_garden;
import '../pages/chat/chat_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, this.currentIndex = 0});

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.yard_rounded, label: 'My Garden'),
    _NavItem(icon: Icons.medical_services_rounded, label: 'Care'),
    _NavItem(icon: Icons.store_rounded, label: 'Market'),
    _NavItem(icon: Icons.people_alt_rounded, label: 'Community'),
  ];

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Already on this page

    HapticFeedback.selectionClick();

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const plant_garden.GardenPage();
        break;
      case 2:
        // Care page not developed yet — do nothing
        return;
      case 3:
        page = const MarketplacePage();
        break;
      case 4:
        page = const ChatPage();
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // --- White floating pill bar with nav items ---
          Positioned(
            bottom: 20,
            left: 24,
            right: 24,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _navItems.length,
                  (index) => _buildNavItem(context, index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final item = _navItems[index];
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFB0BEC5),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFB0BEC5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
