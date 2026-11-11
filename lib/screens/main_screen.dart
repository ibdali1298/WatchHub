import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

// ✨ Saari Screens Import karein
import 'home_screen.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // ✨ PAGES LIST (Yahan humne fix lagaya hai)
  final List<Widget> _pages = [
    // 1. Home
    const HomeScreen(),
    
    // 2. Cart (Fix: isFromBottomNav = true)
    // Is se Back button nahi aayega aur crash nahi hoga
    const CartScreen(isFromBottomNav: true),
    
    // 3. Orders (Fix: isFromProfile = false)
    // Is se bhi Back button nahi aayega
    const MyOrdersScreen(isFromProfile: false),
    
    // 4. Profile
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // Jo index select hoga, wo page dikhega
      body: _pages[_selectedIndex],

      // ================= BOTTOM NAVIGATION BAR =================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.primaryBlue.withOpacity(0.1),
            labelTextStyle: MaterialStateProperty.all(
              GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          child: NavigationBar(
            height: 70,
            backgroundColor: Colors.white,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.primaryBlue),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag, color: AppColors.primaryBlue),
                label: 'Cart',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping, color: AppColors.primaryBlue),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: AppColors.primaryBlue),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}