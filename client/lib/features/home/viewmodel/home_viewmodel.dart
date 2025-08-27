import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spotify_clone/core/models/fav_song_model.dart';
import 'package:flutter_spotify_clone/core/providers/current_user_notifier.dart';
import 'package:flutter_spotify_clone/core/utils.dart';
import 'package:flutter_spotify_clone/features/home/repositories/home_repository.dart';
import 'package:flutter_spotify_clone/features/home/repositories/home_local_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/song_model.dart';

part 'home_viewmodel.g.dart';

@riverpod
Future<List<Song>> getAllSongs(Ref ref) async {
  final token = ref.watch(currentUserNotifierProvider.select((user) => user!.token));
  final res = await ref.watch(homeRepositoryProvider).getAllSongs(token);

  return switch (res) {
    Left(value: final error) => throw error.message,
    Right(value: final songsList) => songsList,
  };
}

@riverpod
Future<List<Song>> getFavSongs(Ref ref) async {
  final token = ref.watch(currentUserNotifierProvider.select((user) => user!.token));
  final res = await ref.watch(homeRepositoryProvider).getFavSongs(token);

  return switch (res) {
    Left(value: final error) => throw error.message,
    Right(value: final songsList) => songsList,
  };
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late HomeRepository _homeRepository;
  late HomeLocalRepository _homeLocalRepository;

  @override
  AsyncValue? build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  Future<void> uploadSong(
    File selectedAudio,
    File selectedThumbnail,
    String songName,
    String artist,
    Color selectedColor,
  ) async {
    state = const AsyncLoading();

    final res = await _homeRepository.uploadSong(
      selectedAudio,
      selectedThumbnail,
      songName,
      artist,
      rgbToHex(selectedColor),
      ref.read(currentUserNotifierProvider)!.token,
    );

    final val = switch (res) {
      Left(value: final l) => state = AsyncError(l.message, StackTrace.current),
      Right(value: final r) => state = AsyncData(r),
    };
    print(val);
  }

  List<Song> getRecentlySongs() {
    return _homeLocalRepository.loadSongs();
  }

  Future<void> favSongs(String songId) async {
    state = const AsyncLoading();

    final res = await _homeRepository.favSongs(
      songId,
      ref.read(currentUserNotifierProvider)!.token,
    );

    final val = switch (res) {
      Left(value: final l) => state = AsyncError(l.message, StackTrace.current),
      Right(value: final r) => _favSongSuccess(r, songId),
    };
    print(val);
  }

  AsyncValue _favSongSuccess(bool isFavorite, String song_id) {
    final userNotifier = ref.read(currentUserNotifierProvider.notifier);
    if (isFavorite) {
      userNotifier.addUser(
        ref
            .read(currentUserNotifierProvider)!
            .copyWith(
              favorites: [
                ...ref.read(currentUserNotifierProvider)!.favorites,
                FavSongModel(id: '', song_id: song_id, user_id: ''),
              ],
            ),
      );
    } else {
      userNotifier.addUser(
        ref
            .read(currentUserNotifierProvider)!
            .copyWith(
              favorites:
                  ref
                      .read(currentUserNotifierProvider)!
                      .favorites
                      .where((fav) => fav.song_id != song_id)
                      .toList(),
            ),
      );
    }
    ref.invalidate(getFavSongsProvider);
    return state = AsyncData(isFavorite);
  }
}
