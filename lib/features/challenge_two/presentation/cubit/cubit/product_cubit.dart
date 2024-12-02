import 'package:bloc/bloc.dart';
import 'package:challenges/core/pagination.dart';
import 'package:challenges/features/challenge_two/data/repository.dart/product_repository_impl.dart';
import 'package:challenges/features/challenge_two/domain/models/product.dart';
import 'package:challenges/features/challenge_two/domain/repository/product_repository.dart';
import 'package:equatable/equatable.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(const ProductState());

  final ProductRepository productRepository = ProductRepositoryImpl();

  final maxPage = 2500;

  void fetchProducts(int page) async {
    if (state.status == PaginationStatus.loading && page != 1) return;

    emit(state.copyWith(status: PaginationStatus.loading, isModified: false));

    final products = await productRepository.getProduct(page);

    emit(state.copyWith(
      products: page == 1 ? products : [...state.products, ...products],
      status: PaginationStatus.loaded,
      hasReachedMax: page == maxPage,
    ));
  }

  void filterProducts(String category, double minPrice, double maxPrice) async {
    if (state.status == PaginationStatus.loading) return;

    emit(state.copyWith(status: PaginationStatus.loading, isModified: true));

    final list = await productRepository.filterProducts(
      state.products,
      category,
      minPrice,
      maxPrice,
    );

    emit(state.copyWith(products: list, status: PaginationStatus.loaded));
  }

  void sortProducts(String criteria) async {
    if (state.status == PaginationStatus.loading) return;

    emit(state.copyWith(status: PaginationStatus.loading, isModified: true));

    final list = await productRepository.sortProducts(state.products, criteria);

    emit(state.copyWith(products: list, status: PaginationStatus.loaded));
  }
}