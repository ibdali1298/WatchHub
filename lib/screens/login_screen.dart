import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import 'register_screen.dart';
import 'admin/admin_dashboard.dart'; 
import 'main_screen.dart'; // ✨ IMPORT CHANGED (Home ki jagah MainScreen)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red));
      return;
    }

    setState(() { isLoading = true; });

    try {
      // 1. Firebase Login
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Check Role (Admin or User)
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc.get('role'); 

        if (!mounted) return;

        if (role == 'admin') {
          // Admin -> Admin Dashboard
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Welcome Admin!"), backgroundColor: Colors.black));
        } else {
          // User -> Main Screen (Bottom Bar)
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen())); // ✨ CHANGED HERE
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful!"), backgroundColor: Colors.green));
        }
      } else {
         // Agar data nahi mila to User man kar MainScreen bhejo
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen())); // ✨ CHANGED HERE
      }

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Login Failed"), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() { isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  child: SizedBox(
                    height: 150, width: 400,
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInDown(child: Text("Welcome Back!", style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.black))),
                
                const SizedBox(height: 40),

                FadeInUp(child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryBlue), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                )),
                const SizedBox(height: 20),
                FadeInUp(child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password", prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                )),

                const SizedBox(height: 30),

                FadeInUp(
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : loginUser,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("LOGIN", style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                FadeInUp(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                        child: const Text("Register", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}