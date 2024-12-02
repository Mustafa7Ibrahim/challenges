import 'package:challenges/features/challenge_two/domain/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProduct(int page);

  Future<List<Product>> filterProducts(
    List<Product> products,
    String category,
    double minPrice,
    double maxPrice,
  );

  Future<List<Product>> sortProducts(
    List<Product> products,
    String criteria,
  );
}
