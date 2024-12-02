part of 'product_cubit.dart';

final class ProductState extends Equatable {
  final List<Product> products;
  final PaginationStatus status;
  final int itemsPerPage;
  final bool hasReachedMax;
  final bool isModified;

  const ProductState({
    this.products = const [],
    this.status = PaginationStatus.loading,
    this.itemsPerPage = 20,
    this.hasReachedMax = false,
    this.isModified = false,
  });

  ProductState copyWith({
    List<Product>? products,
    PaginationStatus? status,
    int? itemsPerPage,
    bool? hasReachedMax,
    bool? isModified,
  }) {
    return ProductState(
      products: products ?? this.products,
      status: status ?? this.status,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isModified: isModified ?? this.isModified,
    );
  }

  @override
  List<Object?> get props => [products, status, itemsPerPage, hasReachedMax, isModified];
}
