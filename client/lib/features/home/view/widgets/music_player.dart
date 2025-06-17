import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spotify_clone/core/theme/app_pallete.dart';
import 'package:flutter_spotify_clone/core/utils.dart';

import '../../../../core/providers/current_song_notifier.dart';
import '../../../../core/providers/current_user_notifier.dart';
import '../../viewmodel/home_viewmodel.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.watch(currentSongNotifierProvider.notifier);
    var userFavorites = ref.watch(
      currentUserNotifierProvider.select((data) => data!.favorites),
    );
    final recentlySongPlayed =
        ref.watch(homeViewModelProvider.notifier).getRecentlySongs();
    var indexOfRecentlySongPlayed = recentlySongPlayed.length - 1;

    return recentlySongPlayed.isNotEmpty
        ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexToColor(
                  recentlySongPlayed[indexOfRecentlySongPlayed].hex_code,
                ),
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
                            image: NetworkImage(
                              recentlySongPlayed[indexOfRecentlySongPlayed]
                                  .thumbnail_url,
                            ),
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
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recentlySongPlayed[indexOfRecentlySongPlayed]
                                    .song_name,
                                style: const TextStyle(
                                  color: Palette.whiteColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                recentlySongPlayed[indexOfRecentlySongPlayed]
                                    .artist,
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
                                  .favSongs(
                                    recentlySongPlayed[indexOfRecentlySongPlayed]
                                        .id,
                                  );
                            },
                            icon:
                                userFavorites
                                        .where(
                                          (fav) =>
                                              fav.song_id ==
                                              recentlySongPlayed[indexOfRecentlySongPlayed]
                                                  .id,
                                        )
                                        .toList()
                                        .isNotEmpty
                                    ? Icon(CupertinoIcons.heart_fill)
                                    : Icon(CupertinoIcons.heart),
                            color: Palette.whiteColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // In your MusicPlayer widget, update the StreamBuilder part with this code:

                      StreamBuilder(
                        stream: songNotifier.audioPlayer!.positionStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox();
                          }

                          final position = snapshot.data;
                          final duration = songNotifier.audioPlayer!.duration;
                          double sliderValue = 0.0;

                          if (position != null && duration != null && duration.inMilliseconds > 0) {
                            // Ensure the value is clamped between 0.0 and 1.0
                            sliderValue = (position.inMilliseconds / duration.inMilliseconds)
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
                                    '${position?.inMinutes}:${((position?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Palette.subtitleText,
                                    ),
                                  ),
                                  Expanded(child: SizedBox()),
                                  Text(
                                    '${duration?.inMinutes}:${((duration?.inSeconds ?? 0) % 60).toString().padLeft(2, '0')}',
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
                      ),

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
                                color:
                                    ref
                                            .watch(
                                              currentSongNotifierProvider
                                                  .notifier,
                                            )
                                            .isShuffle
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
                              // recentlySongPlayed.add(currentSong!);
                              songNotifier.playPause();
                            },
                            icon:
                                songNotifier.isPlaying
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
                                songNotifier.playNextSong();
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
                                color:
                                    ref
                                            .watch(
                                              currentSongNotifierProvider
                                                  .notifier,
                                            )
                                            .isRepeated
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
}
