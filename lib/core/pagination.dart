library pagination;

import 'package:flutter/material.dart';

enum PaginationStatus { loading, loaded, error }

/// builder function type for displaying pagination for a sliver list.
typedef SliverPaginationBuilder<T> = Widget Function(List<T> data, BuildContext context);

/// Error widget builder for load more errors.
typedef ErrorLoadMoreWidget = Widget Function(int page);

/// A widget that provides paginated view for items of type [T].
class Pagination<T> extends StatefulWidget {
  const Pagination({
    super.key,
    required this.hasReachedMax,
    required this.itemsPerPage,
    required this.onLoadMore,
    required this.status,
    required this.data,
    required this.builder,
    this.errorWidget,
    this.errorLoadMoreWidget,
    this.physics,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.emptyWidget,
  });

  final bool hasReachedMax;
  final int itemsPerPage;
  final List<T> data;
  final void Function(int) onLoadMore;
  final PaginationStatus status;
  final Widget? errorWidget;
  final ErrorLoadMoreWidget? errorLoadMoreWidget;
  final ScrollPhysics? physics;
  final CrossAxisAlignment crossAxisAlignment;
  final Widget? emptyWidget;
  final SliverPaginationBuilder<T> builder;

  @override
  State<Pagination<T>> createState() => _PaginationState<T>();
}

class _PaginationState<T> extends State<Pagination<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late final int _loadThreshold = widget.itemsPerPage - 3;

  int get _page => widget.data.length ~/ widget.itemsPerPage + 1;

  void _loadMore() {
    if (_isLoading || widget.hasReachedMax) return;
    _isLoading = true;
    widget.onLoadMore(_page);
    Future.delayed(const Duration(milliseconds: 100), () => _isLoading = false);
  }

  void _checkAndLoadDataIfNeeded() {
    if (widget.hasReachedMax ||
        widget.status == PaginationStatus.loading ||
        widget.status == PaginationStatus.error) return;

    if (widget.data.length <= _loadThreshold && _page < 2) {
      _loadMore();
    }
  }

  bool _onScrollNotification(ScrollNotification scrollInfo) {
    if (widget.hasReachedMax ||
        widget.status == PaginationStatus.loading ||
        widget.status == PaginationStatus.error) return false;

    if (scrollInfo is ScrollUpdateNotification) {
      final remainingScroll =
          _scrollController.position.maxScrollExtent - scrollInfo.metrics.pixels;
      if (remainingScroll <= 100) {
        _loadMore();
      }
    }
    return false;
  }

  @override
  void didUpdateWidget(covariant Pagination<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAndLoadDataIfNeeded();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFirstPageLoading = widget.status == PaginationStatus.loading && _page == 1;
    final bool isFirstPageError = widget.status == PaginationStatus.error && _page == 1;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: CustomScrollView(
        controller: _scrollController,
        physics: widget.physics,
        slivers: [
          // First page loading
          if (isFirstPageLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),

          // First page error
          if (isFirstPageError)
            SliverFillRemaining(
              child: widget.errorWidget ?? const Center(child: Text('Error loading data')),
            ),

          // No data available
          if (widget.data.isEmpty)
            SliverFillRemaining(
              child: widget.emptyWidget ?? const Center(child: Text('No data available')),
            ),

          // Data builder
          if (widget.data.isNotEmpty) widget.builder(widget.data, context),

          // Loading more indicator
          if (widget.status == PaginationStatus.loading && _page > 1)
            const SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
              ),
            ),

          // Load more error
          if (widget.status == PaginationStatus.error && _page > 1)
            SliverToBoxAdapter(
              child: widget.errorLoadMoreWidget?.call(_page) ??
                  const Center(child: Text('Error loading data')),
            ),
        ],
      ),
    );
  }
}
