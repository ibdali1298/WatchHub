import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  // ✨ UPDATED: Saari images ab .png hain
  final List<Map<String, String>> contents = [
    {
      "title": "Timeless Elegance",
      "desc": "Discover a world where precision meets luxury. Find the perfect timepiece for your wrist.",
      "image": "assets/images/onboarding1.png", 
    },
    {
      "title": "Express Delivery",
      "desc": "From our store to your door in record time. Safe, secure, and lightning fast shipping.",
      "image": "assets/images/onboarding2.png", // ✅ Fixed
    },
    {
      "title": "Secure Transactions",
      "desc": "Experience worry-free shopping with our military-grade encrypted payment gateways.",
      "image": "assets/images/onboarding3.png", // ✅ Fixed
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BACKGROUND DECORATION
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 2. MAIN CONTENT
          Column(
            children: [
              // PAGE VIEW (Slider)
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: contents.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // IMAGE WITH ANIMATION
                          ZoomIn(
                            child: Container(
                              height: size.height * 0.4, 
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(contents[index]['image']!),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: size.height * 0.05), 
                          
                          // TEXT CONTENT
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: Column(
                              children: [
                                Text(
                                  contents[index]['title']!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  contents[index]['desc']!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 3. BOTTOM NAVIGATION AREA
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // DOTS INDICATOR
                    Row(
                      children: List.generate(
                        contents.length,
                        (index) => buildDot(index),
                      ),
                    ),

                    // CIRCULAR BUTTON
                    GestureDetector(
                      onTap: () {
                        if (_currentIndex == contents.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()));
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Progress Bar
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(
                              value: (_currentIndex + 1) / contents.length,
                              color: AppColors.primaryBlue,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              strokeWidth: 3,
                            ),
                          ),
                          // Button Icon
                          Container(
                            height: 50,
                            width: 50,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.blueAccent, blurRadius: 10, offset: Offset(0, 4))]
                            ),
                            child: Icon(
                              _currentIndex == contents.length - 1 ? Icons.check : Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentIndex == index ? 30 : 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentIndex == index ? AppColors.primaryBlue : const Color(0xFFD8D8D8),
      ),
    );
  }
}