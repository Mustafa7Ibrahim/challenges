import 'dart:isolate';

import 'package:challenges/features/challenge_two/domain/models/product.dart';
import 'package:challenges/features/challenge_two/domain/repository/product_repository.dart';

class ProductRepositoryImpl extends ProductRepository {
  @override
  Future<List<Product>> getProduct(int page) async {
    // Simulating fetching a product
    return Future.delayed(const Duration(seconds: 2), () {
      return List<Product>.generate(
        20,
        (index) => Product(
          id: 'id$index',
          name: 'Product $index -- $page',
          category: index % 3 == 0 ? 'Electronics' : 'Fashion',
          price: (index % 100) * 10.0,
          rating: (index % 5) + 1.0,
          isAvailable: index % 2 == 0,
        ),
      );
    });
  }

  // filter products by category, minPrice, and maxPrice
  // in an isolated environment
  @override
  Future<List<Product>> filterProducts(
    List<Product> products,
    String category,
    double minPrice,
    double maxPrice,
  ) async {
    return Isolate.run<List<Product>>(() {
      return products.where((product) {
        return product.category == category &&
            product.price >= minPrice &&
            product.price <= maxPrice;
      }).toList();
    });
  }

  // sort products based on criteria
  // in an isolated environment
  @override
  Future<List<Product>> sortProducts(
    List<Product> products,
    String criteria,
  ) async {
    return Isolate.run<List<Product>>(() {
      if (criteria == 'price') {
        products.sort((a, b) => a.price.compareTo(b.price));
      } else if (criteria == 'rating') {
        products.sort((a, b) => b.rating.compareTo(a.rating));
      }
      return products;
    });
  }
}
