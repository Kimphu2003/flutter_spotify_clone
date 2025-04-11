
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

  void uploadLocalSong(Song song) {
    box.put(song.id, song.toJson());
  }

  List<Song> loadSongs() {
    List<Song> songs = [];
    for(final key in box.keys) {
      songs.add(Song.fromJson(box.get(key)));
    }
    return songs;
  }
}