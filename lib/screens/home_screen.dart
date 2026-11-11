import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; // Animations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_drawer.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  String selectedCategory = "All"; 

  // Categories Data
  final List<Map<String, dynamic>> categories = [
    {"name": "All", "icon": Icons.grid_view},
    {"name": "Luxury", "icon": Icons.diamond_outlined},
    {"name": "Smart", "icon": Icons.watch_later_outlined},
    {"name": "Sports", "icon": Icons.directions_run},
    {"name": "Classic", "icon": Icons.access_time},
  ];

  @override
  Widget build(BuildContext context) {
    // Responsive Logic
    double screenWidth = MediaQuery.of(context).size.width;
    int gridCount = screenWidth > 600 ? 4 : 2; // Tablet par 4, Mobile par 2

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean White-Grey Background
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= 1. HEADER & SEARCH (Animated) =================
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 25),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu, color: Colors.white, size: 28), onPressed: () => Scaffold.of(context).openDrawer())),
                            Column(
                              children: [
                                Text("Location", style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
                                Row(children: [const Icon(Icons.location_on, color: Colors.white, size: 16), const SizedBox(width: 4), Text("New York, USA", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold))]),
                              ],
                            ),
                            // Cart Icon with Badge
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.shopping_bag_outlined, color: Colors.white)),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('cart').snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                                      return Positioned(
                                        right: -5, top: -5,
                                        child: ZoomIn(
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                            child: Text('${snapshot.data!.docs.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchText = val.toLowerCase()),
                            decoration: InputDecoration(
                              hintText: "Search for watches...",
                              hintStyle: GoogleFonts.lato(color: Colors.grey),
                              prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                              suffixIcon: _searchText.isNotEmpty ? IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() => _searchText = ""); }) : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      // Categories
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedCategory == categories[index]['name'];
                            return GestureDetector(
                              onTap: () => setState(() => selectedCategory = categories[index]['name']),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(15), 
                                        border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.transparent, width: 2)
                                      ), 
                                      child: Icon(categories[index]['icon'], color: isSelected ? AppColors.primaryBlue : Colors.white, size: 24)
                                    ), 
                                    const SizedBox(height: 8), 
                                    Text(categories[index]['name'], style: GoogleFonts.lato(color: Colors.white, fontSize: 12, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold))
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            
            // ================= BODY CONTENT =================
            Column(
              children: [
                const SizedBox(height: 20),
                
                // 2. BANNER CAROUSEL (With Animations)
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: const BannerCarousel()
                ), 
                
                const SizedBox(height: 20),
                
                // 3. POPULAR BRANDS MARQUEE
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildBrandChip("Rolex"),
                        _buildBrandChip("Casio"),
                        _buildBrandChip("Fossil"),
                        _buildBrandChip("Apple"),
                        _buildBrandChip("Samsung"),
                        _buildBrandChip("Garmin"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Grid Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_searchText.isNotEmpty ? "Search Results" : (selectedCategory == "All" ? "New Arrivals" : "$selectedCategory Watches"), style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                      if(_searchText.isEmpty)
                        GestureDetector(onTap: () => setState(() => selectedCategory = "All"), child: const Text("View All", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                
                const SizedBox(height: 15),

                // 4. PRODUCT GRID (Responsive & Filtered)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('products').orderBy('createdAt', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No products found"));

                      // Client Side Filtering
                      var products = snapshot.data!.docs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        String name = data['name'].toString().toLowerCase();
                        String category = data['category'].toString();
                        bool categoryMatch = selectedCategory == "All" || category == selectedCategory;
                        bool searchMatch = name.contains(_searchText);
                        return categoryMatch && searchMatch;
                      }).toList();

                      if (products.isEmpty) return Center(child: Padding(padding: const EdgeInsets.only(top: 30), child: Text("No watches found", style: GoogleFonts.lato(color: Colors.grey))));

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCount,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemBuilder: (context, index) {
                          var data = products[index].data() as Map<String, dynamic>;
                          return FadeInUp(
                            delay: Duration(milliseconds: 100 * index), // Staggered Animation
                            child: GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(name: data['name'], price: data['price'].toString(), image: data['image'] ?? '', description: data['description'] ?? '', category: data['category'] ?? 'General'))),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10), 
                                          child: Hero(
                                            tag: data['name'],
                                            child: Image.asset(data['image'] ?? '', fit: BoxFit.contain, errorBuilder: (c,o,s)=>const Icon(Icons.watch, size: 50, color: Colors.grey))
                                          )
                                        )
                                      )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("\$${data['price']}", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 15)),
                                              const Icon(Icons.add_circle, color: AppColors.primaryBlue, size: 22),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // ================= 🔥 5. SALE BANNER (Professional) =================
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1E1E2C), Color(0xFF2D2D44)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(4)), child: const Text("SALE 50%", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                              const SizedBox(height: 10),
                              Text("Rolex Special\nEdition", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text("Ends in 24h 12m", style: GoogleFonts.lato(color: Colors.grey[400], fontSize: 12)),
                              const SizedBox(height: 15),
                              ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), minimumSize: const Size(100, 36)), child: const Text("Shop Now", style: TextStyle(color: Colors.white, fontSize: 12))),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2, 
                          child: Image.asset(
                            'assets/images/rolex_sub.jpg', // ✨ Ensure this matches your asset name (jpg/png)
                            fit: BoxFit.contain, 
                            height: 100,
                            errorBuilder: (c,o,s) => const Icon(Icons.watch, color: Colors.white54, size: 60),
                          )
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ================= 🛡️ 6. TRUST SECTION =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text("Why WatchHub?", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFeatureItem(Icons.verified_user_outlined, "Authentic", "100% Original"),
                          _buildFeatureItem(Icons.local_shipping_outlined, "Fast Delivery", "Within 24 Hours"),
                          _buildFeatureItem(Icons.headset_mic_outlined, "Support", "24/7 Online"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ================= 📧 7. NEWSLETTER =================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      const Icon(Icons.mail_outline, size: 40, color: AppColors.primaryBlue),
                      const SizedBox(height: 10),
                      Text("Subscribe & Get 10% Off", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Join our newsletter for latest updates.", style: GoogleFonts.lato(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 15),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          fillColor: Colors.white, filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          suffixIcon: Container(margin: const EdgeInsets.all(5), decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20)),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // ================= 🖤 8. FOOTER =================
                Container(
                  width: double.infinity,
                  color: const Color(0xFF1E1E2C), // Dark Background
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      const Icon(Icons.watch, color: Colors.white, size: 40),
                      const SizedBox(height: 10),
                      Text("WATCH HUB", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 5),
                      Text("Redefining Luxury Timepieces", style: GoogleFonts.lato(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 30),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIcon(Icons.facebook),
                          const SizedBox(width: 20),
                          _buildSocialIcon(Icons.camera_alt),
                          const SizedBox(width: 20),
                          _buildSocialIcon(Icons.alternate_email),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text("© 2025 WatchHub. All rights reserved.", style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildBrandChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
      child: Center(child: Text(label, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.black87))),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))], border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 28),
          const SizedBox(height: 10),
          Text(title, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.lato(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

// ✨ UPDATED BANNER CAROUSEL (With Dots & JPEG fix)
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});
  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _timer;
  
  // ✨ NOTE: Using .jpeg here. Ensure file names match!
  final List<Map<String, String>> bannerData = [
    {"image": "assets/images/banner1.jpeg"}, 
    {"image": "assets/images/banner2.jpeg"}, 
    {"image": "assets/images/banner3.jpeg"}
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentBannerIndex < bannerData.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerIndex, 
          duration: const Duration(milliseconds: 800), 
          curve: Curves.fastOutSlowIn
        );
      }
    });
  }

  @override
  void dispose() { _timer?.cancel(); _bannerController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180, 
          width: double.infinity,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: bannerData.length,
            onPageChanged: (index) => setState(() => _currentBannerIndex = index),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5), 
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), 
                  child: Image.asset(
                    bannerData[index]['image']!, 
                    fit: BoxFit.cover,
                    errorBuilder: (c,o,s) => Container(color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.grey)),
                  )
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerData.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentBannerIndex == index ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index ? AppColors.primaryBlue : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}