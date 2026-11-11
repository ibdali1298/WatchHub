import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';

class CartScreen extends StatefulWidget {
  final bool isFromBottomNav; // ✨ Ye check karega kahan se aaye hain

  // Default value false hai (Matlab Home screen se aaye hain)
  const CartScreen({super.key, this.isFromBottomNav = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  bool isCheckingOut = false;

  // ✨ DELETE ITEM
  Future<void> deleteItem(String docId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('cart')
        .doc(docId)
        .delete();
    
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item Removed"), backgroundColor: Colors.red));
  }

  // ✨ PLACE ORDER
  Future<void> placeOrder(List<QueryDocumentSnapshot> cartItems, double totalAmount) async {
    setState(() => isCheckingOut = true);

    try {
      String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      List<Map<String, dynamic>> items = [];
      for (var item in cartItems) {
        items.add(item.data() as Map<String, dynamic>);
      }

      final orderData = {
        "orderId": orderId,
        "userId": user!.uid,
        "email": user!.email,
        "items": items,
        "totalAmount": totalAmount + 20,
        "status": "Pending",
        "orderDate": Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderData);
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('my_orders').doc(orderId).set(orderData);

      for (var item in cartItems) {
        await item.reference.delete();
      }

      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Order Placed!", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 10),
              Text("Your order ID is #$orderId", style: GoogleFonts.lato(color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (!widget.isFromBottomNav) Navigator.pop(context); // Sirf tab pop karein agar back button tha
              },
              child: const Text("Continue Shopping", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // ✨ LOGIC: Agar Bottom Nav se aaye to Back Button GAYAB
        automaticallyImplyLeading: false, 
        leading: widget.isFromBottomNav 
          ? null // Koi icon nahi
          : IconButton( // Back Icon sirf Home screen se aane par
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
        title: Text("My Cart", style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('cart')
            .orderBy('added_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text("Your Cart is Empty", style: GoogleFonts.lato(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }

          final cartItems = snapshot.data!.docs;
          double subTotal = 0;
          for (var item in cartItems) {
            double price = double.tryParse(item['price'].toString()) ?? 0;
            int qty = item['quantity'] ?? 1;
            subTotal += (price * qty);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var data = cartItems[index].data() as Map<String, dynamic>;
                    String docId = cartItems[index].id;

                    return FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 80, width: 80,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                              child: Image.asset(data['image'] ?? '', fit: BoxFit.contain, errorBuilder: (c,o,s)=>const Icon(Icons.watch)),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 5),
                                  Text("\$${data['price']}", style: GoogleFonts.lato(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => deleteItem(docId),
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Subtotal", style: GoogleFonts.lato(color: Colors.grey)),
                        Text("\$${subTotal.toStringAsFixed(0)}", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Shipping", style: GoogleFonts.lato(color: Colors.grey)),
                        const Text("\$20", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("\$${(subTotal + 20).toStringAsFixed(0)}", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isCheckingOut ? null : () => placeOrder(cartItems, subTotal),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        child: isCheckingOut 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text("Checkout", style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}