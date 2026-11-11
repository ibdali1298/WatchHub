import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/app_colors.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {

  // ✨ STATUS UPDATE FUNCTION
  Future<void> updateStatus(String docId, String currentStatus) async {
    String newStatus = currentStatus == "Pending" ? "Delivered" : "Pending";
    await FirebaseFirestore.instance.collection('orders').doc(docId).update({
      "status": newStatus
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Order Marked as $newStatus"), 
      backgroundColor: newStatus == "Delivered" ? Colors.green : Colors.orange
    ));
  }

  // ✨ DELETE ORDER FUNCTION
  Future<void> deleteOrder(String docId) async {
    await FirebaseFirestore.instance.collection('orders').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Deleted"), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light Grey Background
      appBar: AppBar(
        title: Text("Customer Orders", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue, // Blue Header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('orderDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("No Orders Yet", style: GoogleFonts.lato(color: Colors.grey, fontSize: 18)),
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
              String docId = orders[index].id;
              String status = data['status'] ?? "Pending";
              List<dynamic> items = data['items'] ?? [];

              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      
                      // ✨ HEADER SECTION
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: status == "Delivered" ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          status == "Delivered" ? Icons.check_circle : Icons.local_shipping,
                          color: status == "Delivered" ? Colors.green : Colors.orange,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        data['email'] ?? "Unknown User",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text("Order ID: #${docId.substring(0, 8)}...", style: GoogleFonts.lato(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text("Status: ", style: GoogleFonts.lato(fontSize: 12, color: Colors.grey)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: status == "Delivered" ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              )
                            ],
                          )
                        ],
                      ),
                      
                      // ✨ EXPANDED DETAILS
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Items Ordered:", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 10),
                              
                              ...items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 40, width: 40,
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                        child: Image.asset(item['image'] ?? '', fit: BoxFit.contain, errorBuilder: (c,o,s)=>const Icon(Icons.watch)),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item['name'], style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                                            Text("\$${item['price']}", style: GoogleFonts.lato(color: Colors.grey, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Text("x${item['quantity'] ?? 1}", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              }),

                              const Divider(height: 30),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total Amount", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                                  Text("\$${data['totalAmount']}", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryBlue)),
                                ],
                              ),
                              
                              const SizedBox(height: 20),

                              // ✨ ACTION BUTTONS
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => deleteOrder(docId),
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      label: const Text("Delete", style: TextStyle(color: Colors.red)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => updateStatus(docId, status),
                                      icon: Icon(status == "Pending" ? Icons.check_circle : Icons.refresh, color: Colors.white, size: 18),
                                      label: Text(status == "Pending" ? "Deliver" : "Pending"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: status == "Pending" ? Colors.green : Colors.orange,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                      ),
                                    ),
                                  ),
                                ],
                              )
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