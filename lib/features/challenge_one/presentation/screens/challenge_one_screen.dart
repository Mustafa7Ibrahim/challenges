import 'dart:async';
import 'package:challenges/core/pagination.dart';
import 'package:flutter/material.dart';

class DebuggingTask extends StatelessWidget {
  const DebuggingTask({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debugging Task')),
      body: const Column(
        // separated the two sections into two widgets
        // to separate the state of each widget
        children: [
          Expanded(child: ListPaginationSection()),
          AnimationSection(),
        ],
      ),
    );
  }
}

class ListPaginationSection extends StatefulWidget {
  const ListPaginationSection({super.key});

  @override
  State<ListPaginationSection> createState() => _ListPaginationSectionState();
}

class _ListPaginationSectionState extends State<ListPaginationSection> {
  late final totalPages = 50;
  late final itemsPerPage = 20;
  late final List list = [];

  int currentPage = 1;
  PaginationStatus status = PaginationStatus.loading;

  @override
  void initState() {
    super.initState();
    // start with loading the first page and 20 items
    list.addAll(List.generate(20, (index) => index));
    status = PaginationStatus.loaded;
  }

  /*
    simulate loading more data by doing the following:
    1- by adding 20 items to the list
    2- changing the status to loaded
    3- incrementing the current page
  */
  onLoadMore(page) {
    setState(() => status = PaginationStatus.loading);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        currentPage++;
        list.addAll(List.generate(20, (index) => index));
        status = PaginationStatus.loaded;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    /*
      use the Pagination widget to handle the pagination logic
      and the loading of more data with a sliver list to load lazy items
    */
    return Pagination(
      hasReachedMax: currentPage == totalPages,
      itemsPerPage: itemsPerPage,
      onLoadMore: onLoadMore,
      status: status,
      data: list,
      builder: (data, context) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/50'),
                ),
                title: Text('Item $index'),
              );
            },
            childCount: data.length,
          ),
        );
      },
    );
  }
}

class AnimationSection extends StatefulWidget {
  const AnimationSection({super.key});

  @override
  State<AnimationSection> createState() => _AnimationSectionState();
}

class _AnimationSectionState extends State<AnimationSection> {
  late Timer timer;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) => setState(() => counter++));
  }

  @override
  void dispose() {
    super.dispose();
    // dispose the timer
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      height: counter % 2 == 0 ? 100 : 200,
      width: counter % 2 == 0 ? 100 : 200,
      color: Colors.blue,
    );
  }
}
