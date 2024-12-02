library pagination;

import 'dart:async';
import 'package:flutter/material.dart';

enum PaginationStatus { loading, loaded, error }

typedef SliverPaginationBuilder<T> = Widget Function(List<T> data, BuildContext context);
typedef ErrorLoadMoreWidget = Widget Function(int page);

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
    this.loadThreshold,
    this.scrollThreshold = 200.0,
    this.debounceDuration = const Duration(milliseconds: 300),
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
  final int? loadThreshold;
  final double scrollThreshold;
  final Duration debounceDuration;

  @override
  State<Pagination<T>> createState() => _PaginationState<T>();
}

class _PaginationState<T> extends State<Pagination<T>> {
  late final ScrollController _scrollController;

  Timer? _debounceTimer;

  bool _isLoading = false;

  int _lastCalculatedPage = 1;

  bool _isThrottling = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(_efficientScrollListener);
  }

  void _efficientScrollListener() {
    if (_isLoading ||
        widget.hasReachedMax ||
        widget.status == PaginationStatus.loading ||
        widget.status == PaginationStatus.error) return;

    final scrollPosition = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    if (scrollPosition > maxScrollExtent - widget.scrollThreshold) {
      _triggerLoadMore();
    }
  }

  void _triggerLoadMore() {
    if (_isThrottling) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (_isLoading || widget.hasReachedMax) return;

      _isThrottling = true;
      setState(() => _isLoading = true);

      final currentPage = _calculatePage();

      Future.microtask(() => widget.onLoadMore(currentPage)).whenComplete(() {
        if (mounted) {
          setState(() => _isLoading = false);

          Future.delayed(const Duration(milliseconds: 500), () => _isThrottling = false);
        }
      });
    });
  }

  int _calculatePage() {
    _lastCalculatedPage = widget.data.length ~/ widget.itemsPerPage + 1;
    return _lastCalculatedPage;
  }

  void _checkInitialDataLoad() {
    final loadThreshold = widget.loadThreshold ?? (widget.itemsPerPage * 0.7).round();

    if (widget.data.length <= loadThreshold &&
        !widget.hasReachedMax &&
        widget.status != PaginationStatus.loading) {
      _triggerLoadMore();
    }
  }

  @override
  void didUpdateWidget(covariant Pagination<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data || oldWidget.status != widget.status) {
      _checkInitialDataLoad();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.removeListener(_efficientScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _calculatePage();
    final isFirstPageLoading = widget.status == PaginationStatus.loading && page == 1;
    final isFirstPageError = widget.status == PaginationStatus.error && page == 1;

    return CustomScrollView(
      physics: widget.physics,
      controller: _scrollController,
      slivers: [
        if (isFirstPageLoading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator.adaptive()))
        else if (isFirstPageError)
          SliverFillRemaining(
            child: widget.errorWidget ?? const Center(child: Text('Error loading data')),
          )
        else if (widget.data.isEmpty)
          SliverFillRemaining(
            child: widget.emptyWidget ?? const Center(child: Text('No data available')),
          )
        else
          widget.builder(widget.data, context),
        if (widget.status == PaginationStatus.loading && page > 1)
          const SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(child: CircularProgressIndicator.adaptive()),
              ),
            ),
          ),
        if (widget.status == PaginationStatus.error && page > 1)
          SliverToBoxAdapter(
            child: widget.errorLoadMoreWidget?.call(page) ??
                const Center(child: Text('Error loading data')),
          ),
      ],
    );
  }
}
