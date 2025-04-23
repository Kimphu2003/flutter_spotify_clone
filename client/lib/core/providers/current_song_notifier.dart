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
  late HomeLocalRepository _homeLocalRepository;

  Song? build() {
    _homeLocalRepository = HomeLocalRepository();
    return null;
  }

  void toggleRepeat() {
    isRepeated = !isRepeated;
    // Force notifier to rebuild UI by creating a new copy of the state
    if (state != null) {
      state = state!.copyWith(hex_code: state!.hex_code);
    } else {
      // Just to be safe, handle the case where state is null
      ref.notifyListeners();
    }
  }

  void updateSong(Song song) async {
    await audioPlayer?.stop();
    audioPlayer = AudioPlayer();

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

    // audioPlayer!.playerStateStream.listen((state) {
    //   if (state.processingState == ProcessingState.completed) {
    //     audioPlayer!.seek(Duration.zero);
    //     audioPlayer!.pause();
    //     isPlaying = false;
    //
    //     this.state = this.state?.copyWith(hex_code: this.state?.hex_code);
    //   }
    // });

    _setupCompletionListener();

    _homeLocalRepository.uploadLocalSong(song);

    audioPlayer!.play();
    isPlaying = true;
    state = song;
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

  void _setupCompletionListener() {
    audioPlayer!.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (isRepeated) {
          // If repeat is enabled, seek back to the beginning and play again
          audioPlayer!.seek(Duration.zero);
          audioPlayer!.play();
          isPlaying = true;
        } else {
          // Handle normal completion
          audioPlayer!.seek(Duration.zero);
          audioPlayer!.pause();
          isPlaying = false;
        }
        // Notify UI about state change
        state = state?.copyWith(hex_code: state?.hex_code);
      }
    });
  }
}
