
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/server_constant.dart';
import '../../../core/failure/failure.dart';
import '../models/playlist_model.dart';

part 'playlist_repository.g.dart';

@riverpod
PlaylistRepository playlistRepository(Ref ref) {
  return PlaylistRepository();
}

class PlaylistRepository {
  Future<Either<AppFailure, List<Playlist>>> getUserPlaylists(String token) async {
    try {
      final url = '${ServerConstant.serverURL}/playlists/';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.body.isEmpty) {
        return Left(AppFailure('Empty response from server'));
      }

      dynamic resBodyMap;
      try {
        resBodyMap = jsonDecode(response.body);
      } catch (e) {
        return Left(AppFailure('Invalid response format: ${e.toString()}'));
      }

      if (response.statusCode != 200) {
        if (resBodyMap is Map<String, dynamic> && resBodyMap.containsKey('detail')) {
          return Left(AppFailure(resBodyMap['detail']));
        } else {
          return Left(AppFailure('Error ${response.statusCode}: Could not process server response'));
        }
      }

      if (resBodyMap is! List) {
        return Left(AppFailure('Expected list of playlists but got ${resBodyMap.runtimeType}'));
      }

      List<Playlist> playlists = [];
      for (final item in resBodyMap) {
        try {
          if (item is Map<String, dynamic>) {
            playlists.add(Playlist.fromMap(item));
          }
        } catch (e) {
          print('Error parsing playlist: $e');
        }
      }

      return Right(playlists);
    } on SocketException {
      return Left(AppFailure('Network error: Could not connect to server'));
    } on TimeoutException {
      return Left(AppFailure('Request timed out'));
    } catch (e) {
      return Left(AppFailure('Failed to get playlists: ${e.toString()}'));
    }
  }

  Future<Either<AppFailure, Playlist>> createPlaylist(
      String name,
      String description,
      String token,
      ) async {
    try {
      final url = '${ServerConstant.serverURL}/playlists/';

      final body = jsonEncode({
        'name': name,
        'description': description,
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: body,
      );

      if (response.body.isEmpty) {
        return Left(AppFailure('Empty response from server'));
      }

      dynamic resBodyMap;
      try {
        resBodyMap = jsonDecode(response.body);
      } catch (e) {
        return Left(AppFailure('Invalid response format: ${e.toString()}'));
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (resBodyMap is Map<String, dynamic> && resBodyMap.containsKey('detail')) {
          return Left(AppFailure(resBodyMap['detail']));
        } else {
          return Left(AppFailure('Error ${response.statusCode}: Could not process server response'));
        }
      }

      return Right(Playlist.fromMap(resBodyMap));
    } on SocketException {
      return Left(AppFailure('Network error: Could not connect to server'));
    } on TimeoutException {
      return Left(AppFailure('Request timed out'));
    } catch (e) {
      return Left(AppFailure('Failed to create playlist: ${e.toString()}'));
    }
  }

  Future<Either<AppFailure, Playlist>> getPlaylistWithSongs(String playlistId, String token) async {
    try {
      final url = '${ServerConstant.serverURL}/playlists/$playlistId';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.body.isEmpty) {
        return Left(AppFailure('Empty response from server'));
      }

      dynamic resBodyMap;
      try {
        resBodyMap = jsonDecode(response.body);
      } catch (e) {
        return Left(AppFailure('Invalid response format: ${e.toString()}'));
      }

      if (response.statusCode != 200) {
        if (resBodyMap is Map<String, dynamic> && resBodyMap.containsKey('detail')) {
          return Left(AppFailure(resBodyMap['detail']));
        } else {
          return Left(AppFailure('Error ${response.statusCode}: Could not process server response'));
        }
      }

      return Right(Playlist.fromMap(resBodyMap));
    } on SocketException {
      return Left(AppFailure('Network error: Could not connect to server'));
    } on TimeoutException {
      return Left(AppFailure('Request timed out'));
    } catch (e) {
      return Left(AppFailure('Failed to get playlist details: ${e.toString()}'));
    }
  }

  Future<Either<AppFailure, Map<String, dynamic>>> addSongToPlaylist(
      String playlistId,
      String songId,
      String token
      ) async {
    try {
      final url = '${ServerConstant.serverURL}/playlists/$playlistId/songs/$songId';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.body.isEmpty) {
        return Left(AppFailure('Empty response from server'));
      }

      dynamic resBodyMap;
      try {
        resBodyMap = jsonDecode(response.body);
      } catch (e) {
        return Left(AppFailure('Invalid response format: ${e.toString()}'));
      }

      if (response.statusCode != 200) {
        if (resBodyMap is Map<String, dynamic> && resBodyMap.containsKey('detail')) {
          return Left(AppFailure(resBodyMap['detail']));
        } else {
          return Left(AppFailure('Error ${response.statusCode}: Could not process server response'));
        }
      }

      return Right(resBodyMap);
    } on SocketException {
      return Left(AppFailure('Network error: Could not connect to server'));
    } on TimeoutException {
      return Left(AppFailure('Request timed out'));
    } catch (e) {
      return Left(AppFailure('Failed to add song to playlist: ${e.toString()}'));
    }
  }

  Future<Either<AppFailure, Map<String, dynamic>>> removeSongFromPlaylist(
      String playlistId,
      String songId,
      String token
      ) async {
    try {
      final url = '${ServerConstant.serverURL}/playlists/$playlistId/songs/$songId';

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.body.isEmpty) {
        return Left(AppFailure('Empty response from server'));
      }

      dynamic resBodyMap;
      try {
        resBodyMap = jsonDecode(response.body);
      } catch (e) {
        return Left(AppFailure('Invalid response format: ${e.toString()}'));
      }

      if (response.statusCode != 200) {
        if (resBodyMap is Map<String, dynamic> && resBodyMap.containsKey('detail')) {
          return Left(AppFailure(resBodyMap['detail']));
        } else {
          return Left(AppFailure('Error ${response.statusCode}: Could not process server response'));
        }
      }

      return Right(resBodyMap);
    } on SocketException {
      return Left(AppFailure('Network error: Could not connect to server'));
    } on TimeoutException {
      return Left(AppFailure('Request timed out'));
    } catch (e) {
      return Left(AppFailure('Failed to remove song from playlist: ${e.toString()}'));
    }
  }

  Future<Either<AppFailure, Map<String, dynamic>>> deletePlaylist(String playlistId, String token) async {
    try {
      final url = '${ServerConstant.serverURL}/playlists/$playlistId';

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.statusCode != 200) {
        dynamic resBodyMap;
        try {
          if (response.body.isNotEmpty) {
            resBodyMap = jsonDecode(response.body);
          }
        } catch (_) {}

        if (resBodyMap is Map<String, dynamic> && resBodyMap.containsKey('detail')) {
          return Left(AppFailure(resBodyMap['detail']));
        } else {
          return Left(AppFailure('Error ${response.statusCode}: Could not delete playlist'));
        }
      }

      dynamic resBodyMap;
      try {
        if (response.body.isNotEmpty) {
          resBodyMap = jsonDecode(response.body);
        } else {
          resBodyMap = {'message': 'Playlist deleted'};
        }
      } catch (_) {
        resBodyMap = {'message': 'Playlist deleted'};
      }

      return Right(resBodyMap);
    } on SocketException {
      return Left(AppFailure('Network error: Could not connect to server'));
    } on TimeoutException {
      return Left(AppFailure('Request timed out'));
    } catch (e) {
      return Left(AppFailure('Failed to delete playlist: ${e.toString()}'));
    }
  }

  Future<Either<AppFailure, Playlist>> updatePlaylist(
      String playlistId,
      String name,
      String description,
      String token,
      ) async {
    try {
      final url = '${ServerConstant.serverURL}/playlists/$playlistId';

      final body = jsonEncode({
        'name': name,
        'description': description,
      });

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: body,
      );

      if (response.body.isEmpty) {
        return Left(AppFailure('Empty response from server'));
      }

      dynamic resBodyMap;
      try {
        resBodyMap = jsonDecode(response.body);
      } catch (e) {
        return Left(AppFailure('Invalid response format: ${e.toString()}'));
      }

      if (response.statusCode != 200) {
        if (resBodyMap is Map<String, dynamic> && resBodyMap.containsKey('detail')) {
          return Left(AppFailure(resBodyMap['detail']));
        } else {
          return Left(AppFailure('Error ${response.statusCode}: Could not process server response'));
        }
      }

      return Right(Playlist.fromMap(resBodyMap));
    } on SocketException {
      return Left(AppFailure('Network error: Could not connect to server'));
    } on TimeoutException {
      return Left(AppFailure('Request timed out'));
    } catch (e) {
      return Left(AppFailure('Failed to update playlist: ${e.toString()}'));
    }
  }
}