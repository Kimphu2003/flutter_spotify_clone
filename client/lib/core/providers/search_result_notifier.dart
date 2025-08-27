
import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/home/models/song_model.dart';
import '../../features/home/repositories/home_repository.dart';
import 'current_user_notifier.dart';

part 'search_result_notifier.g.dart';

@riverpod
class SearchResultNotifier extends _$SearchResultNotifier {
  @override
  AsyncValue<List<Song>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    final token = ref.read(currentUserNotifierProvider)!.token;
    final songResult = await ref.read(homeRepositoryProvider).searchSongs(query, token);

    state = switch (songResult) {
      Left(value: final error) => AsyncValue.error(error.message, StackTrace.current),
      Right(value: final songs) => AsyncValue.data(songs),
    };
  }

  void clearResults() {
    state = const AsyncValue.data([]);
  }


}