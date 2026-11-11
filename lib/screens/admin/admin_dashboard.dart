import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_screen.dart';
import 'add_product_screen.dart';
import 'admin_orders_screen.dart'; // ✨ IMPORT ADDED
import '../../utils/app_colors.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: Text("Admin Dashboard", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          // ✨ VIEW ORDERS BUTTON
          IconButton(
            icon: const Icon(Icons.assignment, color: Colors.white),
            tooltip: "View Orders",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOrdersScreen()));
            },
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          )
        ],
      ),
      
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 10),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Manage Your Inventory",
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  "All Products",
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.dashboard_customize_outlined, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text("No Products Found", style: GoogleFonts.lato(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var data = products[index].data() as Map<String, dynamic>;
                    String docId = products[index].id;

                    return FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: Duration(milliseconds: 100 * index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          // Image Section
                          leading: Container(
                            height: 60, width: 60,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
                            child: Image.asset(
                              data['image'] ?? '', 
                              fit: BoxFit.contain,
                              errorBuilder: (c, o, s) => const Icon(Icons.watch, color: Colors.grey),
                            ),
                          ),
                          
                          // Text Details
                          title: Text(data['name'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text("\$${data['price']}", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                          
                          // Delete Button
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: const Text("Delete Product?"),
                                  content: const Text("Are you sure you want to remove this item?"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () {
                                        FirebaseFirestore.instance.collection('products').doc(docId).delete();
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item Deleted")));
                                      },
                                      child: const Text("Delete", style: TextStyle(color: Colors.white)),
                                    )
                                  ],
                                )
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        elevation: 5,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Add Product", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()));
        },
      ),
    );
  }
}