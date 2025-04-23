import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spotify_clone/core/providers/current_song_notifier.dart';
import 'package:flutter_spotify_clone/core/theme/app_pallete.dart';
import 'package:flutter_spotify_clone/core/widgets/loader.dart';
import 'package:flutter_spotify_clone/features/home/view/pages/upload_song_page.dart';
import 'package:flutter_spotify_clone/features/home/viewmodel/home_viewmodel.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(getFavSongsProvider)
        .when(
          data: (data) {
            return ListView.builder(
              itemCount: data.length + 1,
              itemBuilder: (context, index) {
                if (index == data.length) {
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const UploadSongPage(),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 35,
                      backgroundColor: Palette.backgroundColor,
                      child: Icon(CupertinoIcons.add),
                    ),
                    title: Text(
                      'Upload New Song',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }
                final song = data[index];
                return ListTile(
                  onTap: () {
                    ref.read(currentSongNotifierProvider.notifier).updateSong(song);
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(song.thumbnail_url),
                    radius: 35,
                    backgroundColor: Palette.backgroundColor,
                  ),
                  title: Text(
                    song.song_name,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    song.artist,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                );
              },
            );
          },
          error: (error, st) {
            return Center(child: Text(error.toString()));
          },
          loading: () => const Loader(),
        );
  }
}
