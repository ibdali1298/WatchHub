import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';

class MyOrdersScreen extends StatelessWidget {
  final bool isFromProfile; // ✨ New check added

  // Agar Profile se aayein to True, agar Bottom Bar se aayein to False
  const MyOrdersScreen({super.key, this.isFromProfile = false}); 

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown Date";
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("My Orders", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // ✨ Back Button sirf tab dikhega jab Profile se ayenge
        automaticallyImplyLeading: false, 
        leading: isFromProfile 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null, 
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user!.uid)
            // .orderBy('orderDate', descending: true) // ⚠️ ABHI KE LIYE COMMENT KIYA HAI (Niche Padhein)
            .snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  Text("No Orders Yet", style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Start shopping to see your history", style: GoogleFonts.lato(color: Colors.grey)),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var data = orders[index].data() as Map<String, dynamic>;
              String status = data['status'] ?? "Pending";
              List<dynamic> items = data['items'] ?? [];
              String orderId = orders[index].id;
              Timestamp? orderDate = data['orderDate'];

              Color statusColor = status == "Delivered" ? Colors.green : Colors.orange;
              Color statusBg = status == "Delivered" ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1);
              IconData statusIcon = status == "Delivered" ? Icons.check_circle : Icons.local_shipping;

              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                        child: Icon(statusIcon, color: statusColor, size: 24),
                      ),
                      title: Text("Order #${orderId.substring(0, 5)}", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(formatDate(orderDate), style: GoogleFonts.lato(fontSize: 12, color: Colors.grey)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                        child: Text(status, style: GoogleFonts.lato(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                          child: Column(
                            children: [
                              ...items.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 50, width: 50, padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                      child: Image.asset(item['image'] ?? '', fit: BoxFit.contain, errorBuilder: (c,o,s)=>const Icon(Icons.watch, color: Colors.grey)),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['name'] ?? 'Watch', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14)), Text("Qty: ${item['quantity'] ?? 1}", style: GoogleFonts.lato(color: Colors.grey, fontSize: 12))])),
                                    Text("\$${item['price']}", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.black87)),
                                  ],
                                ),
                              )),
                              const Divider(),
                              Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Total Amount", style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[700])), Text("\$${data['totalAmount']}", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 18))]))
                            ],
                          ),
                        )
                      ],
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