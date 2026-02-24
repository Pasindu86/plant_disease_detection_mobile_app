import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomBottomNavBar extends StatefulWidget {
  final VoidCallback onScanTap;

  const CustomBottomNavBar({super.key, required this.onScanTap});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _tapController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Breathing pulse ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Tap scale + glow
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeOut));
    _glowAnimation = Tween<double>(
      begin: 0.35,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _tapController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _tapController.reverse();
    widget.onScanTap();
  }

  void _onTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // --- White floating pill bar ---
          Positioned(
            bottom: 20,
            left: 36,
            right: 36,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // --- Animated pulse ring ---
          Positioned(
            bottom: 24,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final value = _pulseAnimation.value;
                return Container(
                  width: 76 + (value * 12),
                  height: 76 + (value * 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(
                        0xFF4CAF50,
                      ).withOpacity(0.12 * (1 - value)),
                      width: 1.5,
                    ),
                  ),
                );
              },
            ),
          ),

          // --- Scan button ---
          Positioned(
            bottom: 30,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: AnimatedBuilder(
                animation: _tapController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4CAF50),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF4CAF50,
                            ).withOpacity(_glowAnimation.value),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
