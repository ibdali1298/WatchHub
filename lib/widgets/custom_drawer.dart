import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../screens/login_screen.dart';
// ✨ SAARI FILES IMPORT KAREIN
import '../screens/my_orders_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/delivery_address_screen.dart';
import '../screens/settings_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30))),
      child: Column(
        children: [
          // Header (Same as before)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 25, left: 24, right: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
            ),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const CircleAvatar(radius: 30, backgroundImage: AssetImage('assets/images/logo.png'), backgroundColor: Colors.white)),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user?.displayName ?? "User", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text(user?.email ?? "No Email", style: GoogleFonts.lato(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)])),
              ],
            ),
          ),

          // Menu Items (LINKS UPDATED)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildDrawerItem(Icons.shopping_bag_outlined, "My Orders", () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
                }),
                
                // ✨ WISHLIST LINKED
                _buildDrawerItem(Icons.favorite_border, "Wishlist", () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                }),
                
                // ✨ DELIVERY ADDRESS LINKED
                _buildDrawerItem(Icons.location_on_outlined, "Delivery Address", () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryAddressScreen()));
                }),
                
                const Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10), child: Divider(color: Colors.grey)),
                
                // ✨ SETTINGS LINKED
                _buildDrawerItem(Icons.settings_outlined, "Settings", () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                }),
              ],
            ),
          ),

          // Logout (Same as before)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFEBEE), foregroundColor: Colors.red, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(vertical: 15)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.logout, size: 20), const SizedBox(width: 10), Text("Log Out", style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16))]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primaryBlue.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: Row(children: [Icon(icon, color: Colors.grey[700], size: 24), const SizedBox(width: 20), Text(title, style: GoogleFonts.lato(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600)), const Spacer(), Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400])]),
        ),
      ),
    );
  }
}