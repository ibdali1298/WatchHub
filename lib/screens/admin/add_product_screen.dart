import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart'; 

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  String selectedCategory = 'Luxury';
  bool isLoading = false;
  final List<String> categories = ['Luxury', 'Smart', 'Sports', 'Classic', 'Wall'];

  Future<void> uploadProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await FirebaseFirestore.instance.collection('products').add({
          "name": _nameController.text.trim(),
          "price": double.parse(_priceController.text.trim()),
          "image": _imageController.text.trim(),
          "category": selectedCategory,
          "description": _descController.text.trim(),
          "rating": 4.5, 
          "createdAt": Timestamp.now(),
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product Added Successfully!"), backgroundColor: Colors.green));
        Navigator.pop(context); 
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("Add New Watch", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: AppColors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Details", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      const SizedBox(height: 25),
                      
                      _buildTextField(_nameController, "Watch Name", Icons.watch_outlined),
                      const SizedBox(height: 15),
                      _buildTextField(_priceController, "Price (in \$)", Icons.attach_money, isNumber: true),
                      const SizedBox(height: 15),
                      
                      // Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue),
                            items: categories.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: GoogleFonts.lato()),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedCategory = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      _buildTextField(_imageController, "Image Path (e.g. assets/images/p1.jpeg)", Icons.image_outlined),
                      const SizedBox(height: 15),
                      _buildTextField(_descController, "Description", Icons.description_outlined, maxLines: 3),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON (BLUE NOW)
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : uploadProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue, // ✨ BLUE
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 10,
                      shadowColor: AppColors.primaryBlue.withOpacity(0.4),
                    ),
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("UPLOAD PRODUCT", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
      ),
    );
  }
}