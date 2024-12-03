import 'package:challenges/core/pagination.dart';
import 'package:challenges/features/challenge_two/presentation/cubit/cubit/product_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductCubit()..fetchProducts(1),
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Product List'),
              actions: [
                // on tap of each button, the list will be modified
                // and the load more will be disabled
                // this button will filter the list to show only products
                // with category 'Electronics' and price between 100 and 500
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () {
                    context.read<ProductCubit>().filterProducts('Electronics', 100.0, 500.0);
                  },
                ),
                // this button will sort the list based on the price
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () => context.read<ProductCubit>().sortProducts('price'),
                ),
                // this button will reset the list to the original list and enable load more
                IconButton(
                  icon: const Icon(Icons.list_alt_outlined),
                  onPressed: () => context.read<ProductCubit>().fetchProducts(1),
                ),
              ],
            ),

            // use pagination widget to show the list of products
            // with a sliver list builder
            body: Pagination(
              hasReachedMax: state.hasReachedMax,
              itemsPerPage: state.itemsPerPage,
              onLoadMore: (page) {
                state.isModified ? null : context.read<ProductCubit>().fetchProducts(page);
              },
              status: state.status,
              data: state.products,
              builder: (data, context) {
                return SliverList.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final product = data[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
