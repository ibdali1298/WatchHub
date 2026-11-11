import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✨ Firebase Initialize (Aapke project ki settings)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCeyACMTbNFnyErea84M-xRulunc3yGX28",
      authDomain: "watchhub-bd715.firebaseapp.com",
      projectId: "watchhub-bd715",
      storageBucket: "watchhub-bd715.firebasestorage.app",
      messagingSenderId: "323050356550",
      appId: "1:323050356550:web:39c68546610f8ae637af47",
      measurementId: "G-HEFPLFWXD3",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WatchHub',
      debugShowCheckedModeBanner: false, // Debug banner hata diya
      
      // ✨ Global Theme Setup
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        // Text Theme (Google Fonts Globally apply honge)
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      
      // ✨ Starting Point: Splash Screen
      home: const SplashScreen(),
    );
  }
}