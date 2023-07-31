class Product {
  final String id;
  final String name;
  final double price;
  final double discount;
  final String description;
  final List<String> imageUrls;
  int quantity; // Added quantity property

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.discount,
    required this.description,
    required this.imageUrls,
    this.quantity = 1, // Default quantity is 1
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      discount: map['discount']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }
}
