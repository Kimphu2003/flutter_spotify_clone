import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/current_song_notifier.dart';
import '../../../../core/providers/current_user_notifier.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../models/song_model.dart';
import '../../viewmodel/home_viewmodel.dart';

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