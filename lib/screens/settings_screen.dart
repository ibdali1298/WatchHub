import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'static_screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true; // Default
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  // ✨ Load setting from Firestore
  void _loadNotificationSetting() async {
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists && doc.data()!.containsKey('notifications')) {
        setState(() {
          notificationsEnabled = doc['notifications'];
        });
      }
    }
  }

  // ✨ Toggle setting in Firestore
  void _toggleNotifications(bool value) {
    setState(() => notificationsEnabled = value);
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'notifications': value
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light Grey Background
      appBar: AppBar(
        title: Text("Settings", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Edit Profile
          _buildSettingsTile(
            title: "Edit Profile",
            icon: Icons.person,
            color: Colors.blue[100]!,
            iconColor: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
          ),

          // 2. Change Password
          _buildSettingsTile(
            title: "Change Password",
            icon: Icons.lock,
            color: Colors.purple[100]!,
            iconColor: Colors.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen())),
          ),

          // 3. Notifications (Switch)
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              title: Text("Notifications", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.notifications, color: Colors.orange),
              ),
              value: notificationsEnabled,
              activeColor: AppColors.primaryBlue,
              onChanged: _toggleNotifications,
            ),
          ),

          // 4. Privacy Policy
          _buildSettingsTile(
            title: "Privacy Policy",
            icon: Icons.privacy_tip,
            color: Colors.green[100]!,
            iconColor: Colors.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen())),
          ),

          // 5. About Us
          _buildSettingsTile(
            title: "About Us",
            icon: Icons.info,
            color: Colors.indigo[100]!,
            iconColor: Colors.indigo,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))]
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}