
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spotify_clone/features/home/models/song_model.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_local_repository.g.dart';

@riverpod
HomeLocalRepository homeLocalRepository(Ref ref) {
  return HomeLocalRepository();
}

class HomeLocalRepository {
  final Box box = Hive.box();

  static const String _queueKey = 'song_queue';

  void uploadLocalSong(Song song) {
    box.put(song.id, song.toJson());
  }

  List<Song> loadSongs() {
    List<Song> songs = [];
    for(final key in box.keys) {
      if(key != _queueKey) {
        songs.add(Song.fromJson(box.get(key)));
      }
    }
    return songs;
  }

  void addToQueue(Song song) {
    List<String> queue = getQueue();
    queue.add(song.id);
    box.put(_queueKey, queue);
  }

  // void addMultipleToQueue(List<Song> songs) {
  //   List<String> queue = getQueue();
  //   queue.addAll(songs.map((song) => song.id));
  //   box.put(_queueKey, queue);
  // }

  List<String> getQueue() {
    final queueData = box.get(_queueKey);
    if(queueData != null) {
      return List<String>.from(queueData);
    } else {
      return [];
    }
  }

  Song? getNextSongFromQueue() {
    List<String> queue = getQueue();
    if (queue.isEmpty) return null;

    String nextSongId = queue.removeAt(0);
    box.put(_queueKey, queue);

    final songData = box.get(nextSongId);
    if (songData != null) {
      return Song.fromJson(songData);
    }
    return null;
  }

  void removeFromQueue(String songId) {
    List<String> queue = getQueue();
    queue.remove(songId);
    box.put(_queueKey, queue);
  }

  void clearQueue() {
    box.delete(_queueKey);
  }
}