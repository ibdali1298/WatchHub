import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String image;
  final String name;
  final String price;
  final String description;
  final String category;

  const ProductDetailsScreen({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isAddingToCart = false;
  bool isWishlisted = false; 

  @override
  void initState() {
    super.initState();
    checkWishlist();
  }

  // ✨ CHECK WISHLIST STATUS
  void checkWishlist() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .doc(widget.name) 
          .get();
      
      if (doc.exists && mounted) {
        setState(() {
          isWishlisted = true;
        });
      }
    }
  }

  // ✨ TOGGLE WISHLIST
  Future<void> toggleWishlist() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please Login First"), backgroundColor: Colors.red));
      return;
    }

    setState(() {
      isWishlisted = !isWishlisted; 
    });

    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(widget.name);

    if (isWishlisted) {
      await wishlistRef.set({
        "name": widget.name,
        "price": widget.price,
        "image": widget.image,
        "added_at": Timestamp.now(),
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Wishlist"), duration: Duration(milliseconds: 800)));
    } else {
      await wishlistRef.delete();
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from Wishlist"), duration: Duration(milliseconds: 800)));
    }
  }

  // ✨ ADD TO CART
  Future<void> addToCart() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please Login First"), backgroundColor: Colors.red));
      return;
    }

    setState(() => isAddingToCart = true);

    try {
      final cartItem = {
        "name": widget.name,
        "price": widget.price,
        "image": widget.image,
        "quantity": 1,
        "added_at": Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('cart').add(cartItem);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Cart Successfully!"), backgroundColor: Colors.green));
    
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isAddingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isDesktop = size.width > 900;
    double imageHeight = isDesktop ? 450 : 300;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // ✨ Clean Grey Background (Professional Look)
      body: Stack(
        children: [
          // 1. IMAGE AREA (Top Half)
          SizedBox(
            height: size.height * 0.45, // Screen ka 45%
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: widget.name,
                  child: Image.asset(
                    widget.image,
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),

          // 2. HEADER BUTTONS (Back & Wishlist) - Floating Top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BACK BUTTON
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)]
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                    ),
                  ),

                  // ✨ WISHLIST BUTTON (High Visibility)
                  GestureDetector(
                    onTap: toggleWishlist,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)]
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.black, // Active: Red, Inactive: Black
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. DETAILS CONTAINER (Bottom Half)
          Align(
            alignment: Alignment.bottomCenter,
            child: FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: double.infinity,
                height: size.height * 0.58, // Screen ka 58% cover karega
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.category.toUpperCase(),
                            style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 5),
                            Text("4.8 (Reviews)", style: GoogleFonts.lato(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                    
                    const SizedBox(height: 15),

                    // Name
                    Text(
                      widget.name,
                      style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 20),

                    // Features Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFeature(Icons.water_drop_outlined, "Waterproof"),
                        _buildFeature(Icons.timer_outlined, "Automatic"),
                        _buildFeature(Icons.verified_outlined, "Warranty"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Description", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              widget.description.isNotEmpty ? widget.description : "Experience luxury and precision with this masterpiece. Designed for elegance and durability.",
                              style: GoogleFonts.lato(color: Colors.grey[600], height: 1.6, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Price & Add to Cart
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Price", style: GoogleFonts.lato(color: Colors.grey)),
                            Text("\$${widget.price}", style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isAddingToCart ? null : addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Dark Button for professional look
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                            ),
                            child: isAddingToCart 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Text("Add to Cart", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.grey[800]),
          const SizedBox(height: 5),
          Text(label, style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        ],
      ),
    );
  }
}