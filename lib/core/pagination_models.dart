import 'package:flutter/material.dart';

enum PaginationStatus { loading, loaded, error }

typedef SliverPaginationBuilder<T> = Widget Function(List<T> data, BuildContext context);
typedef ErrorLoadMoreWidget = Widget Function(int page);
