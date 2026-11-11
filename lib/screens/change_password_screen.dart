import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart'; // Logout ke baad login par bhejne ke liye

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> _changePassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red));
      return;
    }
    
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password must be at least 6 characters"), backgroundColor: Colors.red));
      return;
    }

    setState(() => isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(_passwordController.text.trim());
        
        if (!mounted) return;
        
        // Password change hone ke baad logout
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Changed! Please Login again."), backgroundColor: Colors.green));
        await FirebaseAuth.instance.signOut();
        
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
      }
    } catch (e) {
      // Note: Agar user ko login kiye hue bohot time ho gaya ho, to Firebase error de sakta hai "Requires Recent Login".
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: Please logout and login again to change password."), backgroundColor: Colors.red));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("Change Password", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.lock_reset, size: 80, color: AppColors.primaryBlue),
            const SizedBox(height: 20),
            Text("Create a new strong password", style: GoogleFonts.lato(color: Colors.grey)),
            const SizedBox(height: 30),
            
            _buildTextField(_passwordController, "New Password"),
            const SizedBox(height: 15),
            _buildTextField(_confirmPasswordController, "Confirm Password"),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text("Update Password", style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}