import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spotify_clone/features/home/viewmodel/home_viewmodel.dart';

import '../../../../core/providers/search_result_notifier.dart';

class CategoryChip extends ConsumerStatefulWidget {
  final TextEditingController searchController;
  final String label;
  final Color color;

  const CategoryChip({
    super.key,
    required this.searchController,
    required this.label,
    required this.color,
  });

  @override
  ConsumerState<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends ConsumerState<CategoryChip> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.searchController.text = widget.label;
        _onSearchChanged(widget.label);
      },
      child: Chip(
        label: Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: widget.color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }

  void _onSearchChanged(String query) {
    Timer debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        ref.read(searchResultNotifierProvider.notifier).searchSongs(query);
      } else {
        ref.read(searchResultNotifierProvider.notifier).clearResults();
      }
    });

    if (debounce.isActive) {
      debounce.cancel();
    }
  }
}
