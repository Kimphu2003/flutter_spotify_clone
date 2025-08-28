import 'dart:math';

import 'package:flutter_spotify_clone/features/home/models/song_model.dart';
import 'package:flutter_spotify_clone/features/home/repositories/home_local_repository.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';

part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  bool isRepeated = false;
  bool isShuffle = false;
  bool _hasSetupListener = false;
  late HomeLocalRepository _homeLocalRepository;

  @override
  Song? build() {
    _homeLocalRepository = HomeLocalRepository();
    ref.onDispose(() {
      print("Disposing CurrentSongNotifier");
      if (audioPlayer != null) {
        audioPlayer!.stop();
        audioPlayer!.dispose();
        audioPlayer = null;
      }
    });

    return null;
  }

  void toggleRepeat() {
    isRepeated = !isRepeated;
    // Force notifier to rebuild UI by creating a new copy of the state
    if (state != null) {
      state = state!.copyWith(hex_code: state!.hex_code);
    } else {
      // handle the case where state is null
      ref.notifyListeners();
    }
  }

  void toggleShuffle() {
    isShuffle = !isShuffle;
    // Force notifier to rebuild UI by creating a new copy of the state
    if (state != null) {
      state = state!.copyWith(hex_code: state!.hex_code);
    } else {
      // handle the case where state is null
      ref.notifyListeners();
    }
  }

  void addToQueue(Song song) {
    _homeLocalRepository.addToQueue(song);
    print("Added to queue: ${song.song_name}");
  }

  void removeFromQueue(String songId) {
    _homeLocalRepository.removeFromQueue(songId);
    print("Removed song from queue");
  }

  void clearQueue() {
    _homeLocalRepository.clearQueue();
    print("Queue cleared");
  }

  void updateSong(Song song) async {
    try {
      print("audioPlayer $audioPlayer");

      if (audioPlayer == null) {
        audioPlayer = AudioPlayer();
        _setupCompletionListener();
      } else {
        if (!_hasSetupListener) {
          _setupCompletionListener();
        }
        await audioPlayer!.stop();
      }

      final audioSource = AudioSource.uri(
        Uri.parse(song.song_url),
        tag: MediaItem(
          id: song.id,
          title: song.song_name,
          artist: song.artist,
          artUri: Uri.parse(song.thumbnail_url),
        ),
      );

      await audioPlayer!.setAudioSource(audioSource);

      audioPlayer!.play();
      isPlaying = true;

      _homeLocalRepository.uploadLocalSong(song);
      state = song;
    } catch (e) {
      print("Error updating song: $e");
      isPlaying = false;
      state = state; // Trigger UI update
    }
  }

  void playPause() {
    if (isPlaying) {
      audioPlayer?.pause();
    } else {
      audioPlayer?.play();
    }
    isPlaying = !isPlaying;
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  void seek(double value) {
    audioPlayer!.seek(
      Duration(
        milliseconds: (value * audioPlayer!.duration!.inMilliseconds).toInt(),
      ),
    );
  }

  Song _getRandomSong() {
    final songs = _homeLocalRepository.loadSongs();
    if (songs.isEmpty) {
      throw Exception("No songs available");
    }

    List<Song> availableSongs = [];

    if (state != null) {
      availableSongs = songs.where((song) => song.id != state!.id).toList();
      print("available songs: $availableSongs");
    } else {
      availableSongs = songs;
    }

    if (availableSongs.isEmpty) {
      availableSongs = songs;
    }

    final random = Random();
    final index = random.nextInt(availableSongs.length);
    print(availableSongs[index]);
    return availableSongs[index];
  }

  void playPreviousSong() {
    try {
      final songs = _homeLocalRepository.loadSongs();
      if (songs.isEmpty) return;

      int currentIndex = 0;
      if (state != null) {
        currentIndex = songs.indexWhere((song) => song.id == state!.id);
        if (currentIndex < 0) currentIndex = 0;
      }

      int prevIndex = (currentIndex - 1);
      if (prevIndex < 0) prevIndex = songs.length - 1;

      updateSong(songs[prevIndex]);
    } catch (e) {
      print("Error playing previous song: $e");
    }
  }

  Song? _getNextSongFromQueue() {
    return _homeLocalRepository.getNextSongFromQueue();
  }

  void playNextSong(Song? song, {bool shuffle = false}) {
    try {
      // First check if there's a song in the queue (unless shuffle is enabled)
      Song? nextSong = song;

      if (nextSong == null && !shuffle && !isShuffle) {
        nextSong = _getNextSongFromQueue();
        if (nextSong != null) {
          print("Playing next song from queue: ${nextSong.song_name}");
          updateSong(nextSong);
          return;
        }
      }

      // If no queue song or shuffle is enabled, use existing logic
      nextSong = nextSong ?? _getRandomSong();

      if (shuffle || isShuffle) {
        print("next song will be: $nextSong");
        updateSong(nextSong);
      } else {
        final songs = _homeLocalRepository.loadSongs();
        if (songs.isNotEmpty && song == null) {
          int currentIndex = 0;
          if (state != null) {
            currentIndex = songs.indexWhere((song) => song.id == state!.id);
            if (currentIndex < 0) currentIndex = 0; // Handle case if song not found
          }
          int nextIndex = (currentIndex + 1) % songs.length;
          print("normal next song: ${songs[nextIndex]}");
          updateSong(songs[nextIndex]);
        } else if (song != null) {
          print("next song: $song");
          updateSong(song);
        }
      }
    } catch (e) {
      print("Error playing next song: $e");
      isPlaying = false;
      state = state; // Trigger UI update
    }
  }

  void setSleepTimer(int totalSeconds) {
    if(totalSeconds <= 0) return;
    Future.delayed(Duration(seconds: totalSeconds), () {
      if(audioPlayer != null && isPlaying) {
        audioPlayer!.pause();
        isPlaying = false;
        state = state?.copyWith(hex_code: state?.hex_code);
      }
    });
  }

  void _setupCompletionListener() {
    if (_hasSetupListener) return;
    _hasSetupListener = true;

    audioPlayer!.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        try {
          if (isRepeated) {
            print("Repeat mode on - playing again.");
            // Make sure that not trigger the slider when seeking to beginning
            audioPlayer!.pause();
            audioPlayer!.seek(Duration.zero).then((_) {
              audioPlayer!.play();
              isPlaying = true;
              state = state?.copyWith(hex_code: state?.hex_code);
            });
          } else {
            print("Song completed - playing next song.");
            // Reset position before playing next
            audioPlayer!.pause();
            audioPlayer!.seek(Duration.zero).then((_) {
              playNextSong(null, shuffle: isShuffle);
            });
          }
        } catch (e) {
          print("Error in completion handler: $e");
          isPlaying = false;
          state = state?.copyWith(hex_code: state?.hex_code);
        }
      }
    });
  }
}
