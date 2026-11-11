class ProductModel {
  final String id;
  final String name;
  final double price; // Price ko number rakhenge taake calculation ho sake
  final String image; // Asset path ya URL
  final String category;
  final String description;
  final double rating;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
    required this.rating,
  });

  // Firebase se data lene ke liye
  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      id: documentId,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      category: data['category'] ?? 'General',
      description: data['description'] ?? 'No description available.',
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }

  // Firebase bhejney ke liye (Admin panel ke liye)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'description': description,
      'rating': rating,
    };
  }
}