import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemThemeWrapper extends StatelessWidget {
  final Widget child;

  const SystemThemeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Read the current system theme (light/dark mode)
    final bool isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Make the status bar background transparent so your page background shows through
        statusBarColor: Colors.transparent,
        
        // Status bar icons: white in dark mode, black in light mode (Android) 
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        
        // Status bar brightness: light in light mode, dark in dark mode (iOS uses this parameter backwards)
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        
        // Ensure the bottom navigation bar matches as well
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: child,
    );
  }
}