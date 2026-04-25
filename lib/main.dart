import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'pages/login/login_page.dart';
import 'pages/home/home_page.dart';
import 'globals.dart';
import 'widgets/animated_chat_button.dart';
import 'widgets/system_theme_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables for Gemini API
  await dotenv.load(fileName: "assets/env/app.env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Google Sign-In
  await GoogleSignIn.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      navigatorObservers: [globalRouteObserver],
      builder: (context, child) {
        return SystemThemeWrapper(
          child: Stack(
            children: [if (child != null) child, const AnimatedChatButton()],
          ),
        );
      },
      title: 'ChillGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4CAF50),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // If user is signed in, skip onboarding since they already did it
          // on login or signup, just go straight to HomePage.
          if (snapshot.hasData) {
            return const HomePage();
          }
          // Otherwise show login
          return const LoginPage();
        },
      ),
    );
  }
}
