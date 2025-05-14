import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spotify_clone/core/providers/current_song_notifier.dart';
import 'package:flutter_spotify_clone/core/providers/current_user_notifier.dart';
import 'package:flutter_spotify_clone/core/providers/search_result_notifier.dart';
import 'package:flutter_spotify_clone/core/theme/app_pallete.dart';
import 'package:flutter_spotify_clone/features/home/models/song_model.dart';
import 'package:flutter_spotify_clone/features/home/viewmodel/home_viewmodel.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Reset search results when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchResultNotifierProvider.notifier).clearResults();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        ref.read(searchResultNotifierProvider.notifier).searchSongs(query);
      } else {
        ref.read(searchResultNotifierProvider.notifier).clearResults();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchResultNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Search',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: 'What do you want to listen to?',
                  hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Palette.subtitleText),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchResultNotifierProvider.notifier).clearResults();
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none
                  ),
                  filled: true,
                  fillColor: Palette.whiteColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16)
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _buildSearchResults(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<Song>> searchState) {
    return searchState.when(
      data: (songs) {
        if (_searchController.text.isEmpty) {
          return _buildSearchSuggestions();
        }

        if (songs.isEmpty) {
          return const Center(
            child: Text(
              'No songs found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return SongListTile(song: song);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error: ${error.toString()}',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    // This could show recent searches or popular categories
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Browse categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip('Hip Hop', Colors.orange),
              _buildCategoryChip('Pop', Colors.blue),
              _buildCategoryChip('Rock', Colors.red),
              _buildCategoryChip('Electronic', Colors.purple),
              _buildCategoryChip('R&B', Colors.pink),
              _buildCategoryChip('Classical', Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, Color color) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _onSearchChanged(label);
      },
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }
}

class SongListTile extends ConsumerWidget {
  final Song song;

  const SongListTile({super.key, required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // Play the song when tapped
        ref.read(currentSongNotifierProvider.notifier).updateSong(song);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Song thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                song.thumbnail_url,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Color(int.parse('0xFF${song.hex_code.replaceAll('#', '')}')),
                    child: const Icon(Icons.music_note, color: Colors.white),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Song details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.song_name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: Palette.subtitleText,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Favorite button
            IconButton(
              icon: Consumer(
                builder: (context, ref, child) {
                  final currentUser = ref.watch(currentUserNotifierProvider);
                  final isFavorite = currentUser?.favorites.any(
                          (fav) => fav.song_id == song.id
                  ) ?? false;

                  return Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.white : null,
                  );
                },
              ),
              onPressed: () {
                ref.read(homeViewModelProvider.notifier).favSongs(song.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}