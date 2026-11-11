import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("My Wishlist", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('wishlist').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text("Wishlist is Empty", style: GoogleFonts.lato(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              var data = items[index].data() as Map<String, dynamic>;
              String docId = items[index].id;

              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Image.asset(data['image'] ?? '', width: 50, fit: BoxFit.contain, errorBuilder: (c,o,s)=>const Icon(Icons.watch)),
                    title: Text(data['name'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                    subtitle: Text("\$${data['price']}", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('wishlist').doc(docId).delete();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from Wishlist")));
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}