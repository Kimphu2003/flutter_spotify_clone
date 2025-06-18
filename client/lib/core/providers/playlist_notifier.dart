import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/home/models/playlist_model.dart';
import '../../features/home/repositories/playlist_repository.dart';
import 'current_user_notifier.dart';

part 'playlist_notifier.g.dart';

@riverpod
class PlaylistsNotifier extends _$PlaylistsNotifier {
  late PlaylistRepository _playlistRepository;

  @override
  AsyncValue<List<Playlist>> build() {
    _playlistRepository = ref.read(playlistRepositoryProvider);
    _loadUserPlaylists();
    return const AsyncValue.loading();
  }

  Future<void> _loadUserPlaylists() async {
    try {
      final user = ref.read(currentUserNotifierProvider);
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final token = user.token;
      final playlistResult = await _playlistRepository.getUserPlaylists(token);

      state = switch (playlistResult) {
        Left(value: final error) =>
            AsyncValue.error(error.message, StackTrace.current),
        Right(value: final playlistsList) => AsyncValue.data(playlistsList),
      };
    } catch (e) {
      print("Error loading user playlists: $e");
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> refreshPlaylists() async {
    state = const AsyncValue.loading();
    await _loadUserPlaylists();
  }

  Future<bool> createPlaylist(String name, String description) async {
    try {
      final user = ref.read(currentUserNotifierProvider);
      if (user == null) {
        print("No user found");
        return false;
      }

      final token = user.token;
      final result = await _playlistRepository.createPlaylist(
        name,
        description,
        token,
      );

      switch (result) {
        case Left(value: final error):
          print("Error creating playlist: ${error.message}");
          state = AsyncValue.error(error.message, StackTrace.current);
          return false;
        case Right(value: final playlist):
          _createdPlaylistSuccess(playlist);
          return true;
      }
    } catch (e) {
      print("Error creating playlist: $e");
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return false;
    }
  }

  void _createdPlaylistSuccess(Playlist playlist) {
    final currentPlaylists = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentPlaylists, playlist]);
  }

  Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    try {
      final user = ref.read(currentUserNotifierProvider);
      if (user == null) {
        print("No user found");
        return false;
      }

      final token = user.token;
      final result = await _playlistRepository.addSongToPlaylist(
        playlistId,
        songId,
        token,
      );

      switch (result) {
        case Right(value: final response):
          print("Successfully added song to playlist");
          // Refresh the playlists to show the updated playlist
          await _refreshPlaylistById(playlistId);
          return true;
        case Left(value: final error):
          print("Error adding song to playlist: ${error.message}");
          state = AsyncValue.error(error.message, StackTrace.current);
          return false;
      }
    } catch (e) {
      print("Error adding song to playlist: $e");
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return false;
    }
  }

  Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final user = ref.read(currentUserNotifierProvider);
      if (user == null) {
        print("No user found");
        return false;
      }

      final token = user.token;
      final result = await _playlistRepository.removeSongFromPlaylist(
        playlistId,
        songId,
        token,
      );

      switch (result) {
        case Right(value: final response):
          print("Successfully removed song from playlist");
          await _refreshPlaylistById(playlistId);
          return true;
        case Left(value: final error):
          print("Error removing song from playlist: ${error.message}");
          state = AsyncValue.error(error.message, StackTrace.current);
          return false;
      }
    } catch (e) {
      print("Error removing song from playlist: $e");
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return false;
    }
  }

  Future<bool> deletePlaylist(String playlistId) async {
    try {
      final user = ref.read(currentUserNotifierProvider);
      if (user == null) {
        print("No user found");
        return false;
      }

      final token = user.token;
      final result = await _playlistRepository.deletePlaylist(
          playlistId, token);

      switch (result) {
        case Right(value: final response):
          print("Successfully deleted playlist");
          // Remove the playlist from the state
          final currentPlaylists = state.valueOrNull ?? [];
          final updatedPlaylists = currentPlaylists.where((playlist) =>
          playlist.id != playlistId).toList();
          state = AsyncValue.data(updatedPlaylists);
          return true;
        case Left(value: final error):
          print("Error deleting playlist: ${error.message}");
          state = AsyncValue.error(error.message, StackTrace.current);
          return false;
      }
    } catch (e) {
      print("Error deleting playlist: $e");
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return false;
    }
  }

  Future<bool> updatePlaylist(String playlistId, String name,
      String description) async {
    try {
      final user = ref.read(currentUserNotifierProvider);
      if (user == null) {
        print("No user found");
        return false;
      }

      final token = user.token;
      final result = await _playlistRepository.updatePlaylist(
        playlistId,
        name,
        description,
        token,
      );

      switch (result) {
        case Right(value: final updatedPlaylist):
          print("Successfully updated playlist");
          // Update the playlist in the state
          final currentPlaylists = state.valueOrNull ?? [];
          final updatedPlaylists = currentPlaylists.map((playlist) {
            if (playlist.id == playlistId) {
              return updatedPlaylist;
            }
            return playlist;
          }).toList();
          state = AsyncValue.data(updatedPlaylists);
          return true;
        case Left(value: final error):
          print("Error updating playlist: ${error.message}");
          state = AsyncValue.error(error.message, StackTrace.current);
          return false;
      }
    } catch (e) {
      print("Error updating playlist: $e");
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return false;
    }
  }

  // Helper method to refresh a specific playlist by fetching its details
  Future<void> _refreshPlaylistById(String playlistId) async {
    try {
      final user = ref.read(currentUserNotifierProvider);
      if (user == null) return;

      final token = user.token;
      final result = await _playlistRepository.getPlaylistWithSongs(
          playlistId, token);

      switch (result) {
        case Right(value: final updatedPlaylist):
          final currentPlaylists = state.valueOrNull ?? [];
          final updatedPlaylists = currentPlaylists.map((playlist) {
            if (playlist.id == playlistId) {
              return updatedPlaylist;
            }
            return playlist;
          }).toList();
          state = AsyncValue.data(updatedPlaylists);
        case Left(value: final error):
          print("Error refreshing playlist: ${error.message}");
      }
    } catch (e) {
      print("Error refreshing playlist: $e");
    }
  }

  // Helper method to get a playlist by ID
  Playlist? getPlaylistById(String playlistId) {
    final playlists = state.valueOrNull;
    if (playlists == null) return null;

    try {
      return playlists.firstWhere(
            (playlist) => playlist.id == playlistId,
      );
    } catch (e) {
      print("Playlist not found: $e");
      return null;
    }
  }

  int getPlaylistSongCount(String playlistId) {
    final playlist = getAllPlaylists();
    if (playlist == null) return 0;

    // Return the number of songs in the playlist
    return playlist.length;
  }

  Playlist? getPlaylistBySongId(String songId) {
    final playlists = state.valueOrNull;
    if (playlists == null) return null;

    try {
      return playlists.firstWhere(
            (playlist) => playlist.songs.any((song) => song.id == songId),
      );
    } catch (e) {
      print("Playlist containing song not found: $e");
      return null;
    }
  }

  List<Playlist>? getAllPlaylists() {
    final playlists = state.valueOrNull;
    if (playlists == null) return null;

    // Return all playlists
    return playlists;
  }
}

  // Helper method to check if a song is in a specific playlist
  // bool isSongInPlaylist(String playlistId, String songId) {
  //   final playlist = getPlaylistById(playlistId);
  //   if (playlist == null) return false;
  //
  //   if (playlist.songs > 0) return true ;
  //
  //   return false;
  // }

  // Force UI update similar to CurrentSongNotifier pattern
  // void _forceUIUpdate() {
  //   if (state.hasValue) {
  //     final currentPlaylists = state.valueOrNull ?? [];
  //     state = AsyncValue.data([...currentPlaylists]);
  //   }
  // }
