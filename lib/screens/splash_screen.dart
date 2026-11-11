import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // 3.5 Second ka Timer
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BACKGROUND DESIGN (Subtle Blue Circles)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // 2. CENTER CONTENT (Logo + Tagline)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO ANIMATION
                FadeInDown(
                  duration: const Duration(milliseconds: 1200),
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    // ✨ UPDATE: Padding kam ki hai (20 -> 12) taake image badi dikhe
                    padding: const EdgeInsets.all(12), 
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain, // Logo ko adjust karega
                        width: 160, // ✨ Width fix kar di taake logo fail kar aaye
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // BRAND NAME ANIMATION
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 1000),
                  child: Text(
                    "WATCH HUB",
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryBlue,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // TAGLINE ANIMATION
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  duration: const Duration(milliseconds: 1000),
                  child: Text(
                    "Discover Luxury. Redefine Time.",
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. BOTTOM LOADER
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: FadeIn(
              delay: const Duration(milliseconds: 1500),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "v1.0.0",
                    style: GoogleFonts.lato(color: Colors.grey[400], fontSize: 10),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}