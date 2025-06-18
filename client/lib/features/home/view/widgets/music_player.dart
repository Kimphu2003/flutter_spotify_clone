import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spotify_clone/core/providers/playlist_notifier.dart';
import 'package:flutter_spotify_clone/core/theme/app_pallete.dart';
import 'package:flutter_spotify_clone/core/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/providers/current_song_notifier.dart';
import '../../../../core/providers/current_user_notifier.dart';
import '../../models/song_model.dart';
import '../../viewmodel/home_viewmodel.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.watch(currentSongNotifierProvider.notifier);
    var userFavorites = ref.watch(
      currentUserNotifierProvider.select((data) => data!.favorites),
    );
    final recentlySongPlayed =
    ref.watch(homeViewModelProvider.notifier).getRecentlySongs();

    // Update the UI when the next song is played (the next song is added to queue through "Add to Queue" action)
    final displaySong = currentSong ??
        (recentlySongPlayed.isNotEmpty ? recentlySongPlayed.last : null);

    return displaySong != null
        ? Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            hexToColor(displaySong.hex_code),
            const Color(0xff121212),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Palette.transparentColor,
        appBar: AppBar(
          backgroundColor: Palette.transparentColor,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: IconButton(
                onPressed: () {
                  _showBottomSheet(context, ref, displaySong);
                },
                icon: Icon(Icons.more_vert, color: Palette.whiteColor),
              ),
            ),
          ],
          leading: Transform.translate(
            offset: Offset(-15, 0),
            child: InkWell(
              highlightColor: Palette.transparentColor,
              focusColor: Palette.transparentColor,
              splashColor: Palette.transparentColor,
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/pull-down-arrow.png',
                  color: Palette.whiteColor,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Hero(
                  tag: 'music-image',
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(displaySong.thumbnail_url),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displaySong.song_name,
                            style: const TextStyle(
                              color: Palette.whiteColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            displaySong.artist,
                            style: const TextStyle(
                              color: Palette.subtitleText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () async {
                          await ref
                              .read(homeViewModelProvider.notifier)
                              .favSongs(displaySong.id);
                        },
                        icon: userFavorites
                            .where((fav) => fav.song_id == displaySong.id)
                            .toList()
                            .isNotEmpty
                            ? Icon(CupertinoIcons.heart_fill)
                            : Icon(CupertinoIcons.heart),
                        color: Palette.whiteColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // StreamBuilder for audio position - only show if audioPlayer exists
                  songNotifier.audioPlayer != null
                      ? StreamBuilder(
                    stream: songNotifier.audioPlayer!.positionStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox();
                      }

                      final position = snapshot.data;
                      final duration = songNotifier.audioPlayer!.duration;
                      double sliderValue = 0.0;

                      if (position != null &&
                          duration != null &&
                          duration.inMilliseconds > 0) {
                        sliderValue = (position.inMilliseconds /
                            duration.inMilliseconds)
                            .clamp(0.0, 1.0);
                      }

                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Palette.whiteColor,
                              inactiveTrackColor: Palette.whiteColor
                                  .withOpacity(0.2),
                              thumbColor: Palette.whiteColor,
                              trackHeight: 4,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              value: sliderValue,
                              min: 0,
                              max: 1,
                              onChanged: (val) => sliderValue = val,
                              onChangeEnd: (val) => songNotifier.seek(val),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${position?.inMinutes ?? 0}:${((position?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Palette.subtitleText,
                                ),
                              ),
                              Expanded(child: SizedBox()),
                              Text(
                                '${duration?.inMinutes ?? 0}:${((duration?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Palette.subtitleText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  )
                      : const SizedBox(height: 50), // Placeholder when no audio player

                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                          onPressed: () {
                            ref
                                .read(currentSongNotifierProvider.notifier)
                                .toggleShuffle();
                          },
                          icon: Image.asset(
                            'assets/images/shuffle.png',
                            color: songNotifier.isShuffle
                                ? Palette.whiteColor
                                : Colors.white54,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                          onPressed: () {
                            songNotifier.playPreviousSong();
                          },
                          icon: Image.asset(
                            'assets/images/previous-song.png',
                            color: Palette.whiteColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          songNotifier.playPause();
                        },
                        icon: songNotifier.isPlaying
                            ? Icon(CupertinoIcons.pause_circle_fill)
                            : Icon(
                          CupertinoIcons.play_circle_fill,
                          color: Palette.whiteColor,
                        ),
                        iconSize: 80,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                          onPressed: () {
                            songNotifier.playNextSong(null);
                          },
                          icon: Image.asset(
                            'assets/images/next-song.png',
                            color: Palette.whiteColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                          onPressed: () {
                            ref
                                .read(currentSongNotifierProvider.notifier)
                                .toggleRepeat();
                          },
                          icon: Image.asset(
                            'assets/images/repeat.png',
                            color: songNotifier.isRepeated
                                ? Palette.whiteColor
                                : Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/connect-device.png',
                          color: Palette.whiteColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/playlist.png',
                          color: Palette.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        : Container();
  }

  void _showBottomSheet(BuildContext context, WidgetRef ref, Song song) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(CupertinoIcons.heart),
              title: const Text('Like'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(homeViewModelProvider.notifier).favSongs(song.id);
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.music_note_list),
              title: const Text('Add to Playlist'),
              onTap: () {
                Navigator.pop(context);
                final playlists = ref.read(playlistsNotifierProvider.notifier).getAllPlaylists();
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: playlists?.length ?? 0,
                        itemBuilder: (context, index) {
                          if(playlists == null || playlists.isEmpty) {
                            return const ListTile(
                              title: Text('No Playlists Available'),
                            );
                          }
                          final playlist = playlists[index];
                          return ListTile(
                            title: Text(playlist.name),
                            onTap: () {
                              ref.read(playlistsNotifierProvider.notifier)
                                  .addSongToPlaylist(playlist.id, song.id);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music),
              title: const Text('Add To Queue'),
              onTap: () {
                Navigator.pop(context);
                ref.read(currentSongNotifierProvider.notifier).addToQueue(song);
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "${song.song_name}" to queue'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.album_outlined),
              title: const Text('View Album'),
              onTap: () {
                Navigator.pop(context);
                // Do album logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_box),
              title: const Text('View Artist'),
              onTap: () {
                Navigator.pop(context);
                // Do artist logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Do share logic
              },
            ),
          ],
        );
      },
    );
  }
}