import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:pashu_swasthya/services/database_helper.dart';
import 'package:pashu_swasthya/screens/navigation_screen.dart';
import 'language_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for at least 3 seconds for splash effect
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Navigate directly to LanguageSelectionScreen since login is removed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.white, // white background to match logo
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo - centered and prominent
              SizedBox(
                width: screenWidth * 0.7,
                height: screenHeight * 0.5,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image fails to load
                    print('Error loading logo: $error');
                    return Icon(
                      Icons.pets,
                      size: 100,
                      color: AppTheme.primaryGreen,
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              // Loading indicator
              const CircularProgressIndicator(
                color: Color(0xFF1B5E20),
                strokeWidth: 3.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
