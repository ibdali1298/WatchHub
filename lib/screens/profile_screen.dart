import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart'; 
import '../utils/app_colors.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart'; 
import 'my_orders_screen.dart';
import 'wishlist_screen.dart';
import 'delivery_address_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  // Logout Function
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER SECTION =================
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Blue Background Curve
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),

                // 2. Profile Picture & Edit Button
                Positioned(
                  bottom: -50,
                  child: FadeInDown(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage('assets/images/logo.png'), 
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        // Edit Icon Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60), // Space for Profile Pic

            // ================= USER INFO =================
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Column(
                children: [
                  Text(
                    user?.displayName ?? "User Name",
                    style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user?.email ?? "email@example.com",
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= MENU OPTIONS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ✨ Yahan Logic update ki hai: isFromProfile: true
                  _buildProfileTile(
                    icon: Icons.shopping_bag_outlined, 
                    title: "My Orders", 
                    color: Colors.orange, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen(isFromProfile: true)))
                  ),
                  _buildProfileTile(
                    icon: Icons.favorite_border, 
                    title: "Wishlist", 
                    color: Colors.red, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()))
                  ),
                  _buildProfileTile(
                    icon: Icons.location_on_outlined, 
                    title: "Delivery Address", 
                    color: Colors.green, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryAddressScreen()))
                  ),
                  _buildProfileTile(
                    icon: Icons.settings_outlined, 
                    title: "Settings", 
                    color: Colors.blue, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= LOGOUT BUTTON =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout),
                        const SizedBox(width: 10),
                        Text("Log Out", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ✨ Helper Widget for Menu Tiles
  Widget _buildProfileTile({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }
}