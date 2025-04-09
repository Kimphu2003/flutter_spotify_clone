import 'dart:io';
import 'dart:ui';

import 'package:flutter_spotify_clone/core/providers/current_user_notifier.dart';
import 'package:flutter_spotify_clone/core/utils.dart';
import 'package:flutter_spotify_clone/features/home/repositories/HomeRepository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late HomeRepository _homeRepository;

  @override
  AsyncValue? build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
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

    final val = switch(res) {
      Left(value: final l) => state = AsyncError(l.message, StackTrace.current),
      Right(value: final r) => state = AsyncData(r)
    };
    print(val);
  }
}
