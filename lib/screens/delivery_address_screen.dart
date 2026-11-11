import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  // Purana address load karna
  void _loadAddress() async {
    var doc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('address').doc('default').get();
    if (doc.exists) {
      setState(() {
        _addressController.text = doc['address'];
        _cityController.text = doc['city'];
        _zipController.text = doc['zip'];
      });
    }
  }

  // Address Save Karna
  void _saveAddress() async {
    setState(() => isLoading = true);
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('address').doc('default').set({
      'address': _addressController.text,
      'city': _cityController.text,
      'zip': _zipController.text,
    });
    setState(() => isLoading = false);
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Address Saved Successfully!"), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Delivery Address", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField(_addressController, "Street Address", Icons.home),
            const SizedBox(height: 15),
            _buildTextField(_cityController, "City", Icons.location_city),
            const SizedBox(height: 15),
            _buildTextField(_zipController, "Zip Code", Icons.map, isNumber: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveAddress,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Address", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}