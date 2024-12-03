library pagination;

import 'dart:async';
import 'package:challenges/core/pagination_models.dart';
import 'package:challenges/core/pagination_state_notifier.dart';
import 'package:flutter/material.dart';

export 'package:challenges/core/pagination_models.dart';

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
  late final ScrollController _scrollController;
  late final PaginationStateNotifier<T> _stateNotifier;
  late bool isAlreadyTriggerMorePage;

  @override
  void initState() {
    super.initState();
    isAlreadyTriggerMorePage = false;
    _scrollController = ScrollController();
    _scrollController.addListener(_efficientScrollListener);

    _stateNotifier = PaginationStateNotifier<T>(
      hasReachedMax: widget.hasReachedMax,
      itemsPerPage: widget.itemsPerPage,
      data: widget.data,
      status: widget.status,
    );
  }

  void _efficientScrollListener() {
    if (_stateNotifier.hasReachedMax.value ||
        _stateNotifier.status.value == PaginationStatus.loading ||
        _stateNotifier.status.value == PaginationStatus.error ||
        isAlreadyTriggerMorePage) return;

    final scrollPosition = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    const fixedThreshold = 500.0;
    bool isRemainingFixedThreshold = (maxScrollExtent - scrollPosition) < fixedThreshold;

    if (isRemainingFixedThreshold) {
      if (isAlreadyTriggerMorePage == false) {
        isAlreadyTriggerMorePage = true;
        _triggerLoadMore();
      }
    }
  }

  void _triggerLoadMore() {
    final currentPage = _stateNotifier.calculatePage();
    Future.microtask(() => widget.onLoadMore(currentPage)).whenComplete(() {
      if (mounted) isAlreadyTriggerMorePage = false;
    });
  }

  @override
  void didUpdateWidget(covariant Pagination<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      _stateNotifier.updateData(widget.data);
    }
    if (oldWidget.status != widget.status) {
      _stateNotifier.updateStatus(widget.status);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_efficientScrollListener);
    _scrollController.dispose();
    _stateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: widget.physics,
      controller: _scrollController,
      slivers: [
        ValueListenableBuilder<PaginationStatus>(
          valueListenable: _stateNotifier.status,
          builder: (context, status, child) {
            final currentPage = _stateNotifier.calculatePage();
            if (status == PaginationStatus.loading && currentPage == 1) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator.adaptive()),
              );
            }
            return const SliverToBoxAdapter();
          },
        ),
        ValueListenableBuilder<PaginationStatus>(
          valueListenable: _stateNotifier.status,
          builder: (context, status, child) {
            final currentPage = _stateNotifier.calculatePage();
            if (status == PaginationStatus.error && currentPage == 1) {
              return SliverFillRemaining(
                child: widget.errorWidget ?? const Center(child: Text('Error loading data')),
              );
            }
            return const SliverToBoxAdapter();
          },
        ),
        ValueListenableBuilder<List<T>>(
          valueListenable: _stateNotifier.data,
          builder: (context, data, child) {
            if (data.isEmpty) {
              return SliverFillRemaining(
                child: widget.emptyWidget ?? const Center(child: Text('No data available')),
              );
            }
            return const SliverToBoxAdapter();
          },
        ),
        ValueListenableBuilder<List<T>>(
          valueListenable: _stateNotifier.data,
          builder: (context, data, child) {
            return widget.builder(data, context);
          },
        ),
        ValueListenableBuilder<PaginationStatus>(
          valueListenable: _stateNotifier.status,
          builder: (context, status, child) {
            final currentPage = _stateNotifier.calculatePage();
            if (status == PaginationStatus.loading && currentPage > 1) {
              return const SliverToBoxAdapter(
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                ),
              );
            }
            return const SliverToBoxAdapter();
          },
        ),
        ValueListenableBuilder<PaginationStatus>(
          valueListenable: _stateNotifier.status,
          builder: (context, status, child) {
            final currentPage = _stateNotifier.calculatePage();
            if (status == PaginationStatus.error && currentPage > 1) {
              return SliverToBoxAdapter(
                child: widget.errorLoadMoreWidget?.call(currentPage) ??
                    const Center(child: Text('Error loading data')),
              );
            }
            return const SliverToBoxAdapter();
          },
        ),
      ],
    );
  }
}
