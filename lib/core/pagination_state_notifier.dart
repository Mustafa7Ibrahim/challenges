import 'package:challenges/core/pagination.dart';
import 'package:flutter/material.dart';

class PaginationStateNotifier<T> {
  PaginationStateNotifier({
    required bool hasReachedMax,
    required int itemsPerPage,
    required List<T> data,
    required PaginationStatus status,
  })  : _hasReachedMax = ValueNotifier<bool>(hasReachedMax),
        _status = ValueNotifier<PaginationStatus>(status),
        _data = ValueNotifier<List<T>>(data),
        _itemsPerPage = itemsPerPage;

  final int _itemsPerPage;

  final ValueNotifier<bool> _hasReachedMax;
  final ValueNotifier<PaginationStatus> _status;
  final ValueNotifier<List<T>> _data;

  ValueNotifier<bool> get hasReachedMax => _hasReachedMax;
  ValueNotifier<PaginationStatus> get status => _status;
  ValueNotifier<List<T>> get data => _data;

  int calculatePage() => _data.value.length ~/ _itemsPerPage + 1;

  void updateData(List<T> newData) => _data.value = newData;

  void updateStatus(PaginationStatus newStatus) => _status.value = newStatus;

  void updateHasReachedMax(bool reachedMax) => _hasReachedMax.value = reachedMax;

  void dispose() {
    _hasReachedMax.dispose();
    _status.dispose();
    _data.dispose();
  }
}
