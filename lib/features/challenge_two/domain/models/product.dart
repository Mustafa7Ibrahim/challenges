class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final bool isAvailable;
  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
      rating: json['rating'],
      isAvailable: json['isAvailable'],
    );
  }
}
