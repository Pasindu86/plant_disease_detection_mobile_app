import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pages/home/home_page.dart';
import '../pages/marketplace/marketplace_page.dart';
import '../pages/garden/garden_page.dart' as plant_garden;
import '../pages/community/community_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onScanTap;

  const CustomBottomNavBar({
    super.key, 
    this.currentIndex = 0, 
    this.onScanTap,
  });

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.local_florist_rounded, label: 'My Garden'),
    _NavItem(icon: Icons.store_rounded, label: 'Market'),
    _NavItem(icon: Icons.people_alt_rounded, label: 'Community'),
  ];

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

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
        page = const MarketplacePage();
        break;
      case 3:
        page = const CommunityPage();
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
      height: 110, // Tall enough to fit the floating center button
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // --- White floating pill bar with nav items ---
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(context, 0),
                        _buildNavItem(context, 1),
                      ],
                    ),
                  ),
                  const SizedBox(width: 60), // Reduced gap to prevent horizontal overflow
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(context, 2),
                        _buildNavItem(context, 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // --- Floating Scan Button ---
          Positioned(
            bottom: 35, // Floats slightly above the bar
            child: GestureDetector(
              onTap: onScanTap,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF5CB85C), // Green color matching the image
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 5, // White stroke around the green button
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5CB85C).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.document_scanner_rounded, // Matches the icon in your image
                  color: Colors.white,
                  size: 32,
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
    
    // Using a slightly more vibrant green for selected state
    final color = isSelected ? const Color(0xFF5CB85C) : const Color(0xFF9E9E9E);
    
    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 24, // Slightly smaller icon
              color: color,
            ),
            const SizedBox(height: 2), // Less vertical space
            Text(
              item.label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10, // Smaller font
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
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
