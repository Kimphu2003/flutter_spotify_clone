import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spotify_clone/core/constants/server_constant.dart';
import 'package:flutter_spotify_clone/core/failure/failure.dart';
import 'package:flutter_spotify_clone/features/home/models/song_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepository();
}

class HomeRepository {
  Future<Either<AppFailure, String>> uploadSong(
    File selectedAudio,
    File selectedThumbnail,
    String songName,
    String artist,
    String hexCode,
    String token,
  ) async {
    try {
      final response = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerConstant.serverURL}/song/upload'),
      );
      response
        ..files.addAll([
          await http.MultipartFile.fromPath('song', selectedAudio.path),
          await http.MultipartFile.fromPath(
            'thumbnail',
            selectedThumbnail.path,
          ),
        ])
        ..fields.addAll({
          'artist': artist,
          'song_name': songName,
          'hex_code': hexCode,
        })
        ..headers.addAll({'x-auth-token': token});

      final res = await response.send();

      if (res.statusCode != 201) {
        return Left(AppFailure(await res.stream.bytesToString()));
      }

      return Right(await res.stream.bytesToString());
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<Song>>> getAllSongs(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ServerConstant.serverURL}/song/list'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      var resBodyMap = jsonDecode(response.body);

      if (response.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }

      resBodyMap = resBodyMap as List;

      List<Song> songs = [];

      for (final map in resBodyMap) {
        songs.add(Song.fromMap(map));
      }
      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<Song>>> getFavSongs(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ServerConstant.serverURL}/song/list/favorite'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      var resBodyMap = jsonDecode(response.body);

      if (response.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }

      resBodyMap = resBodyMap as List;

      List<Song> songs = [];

      for (final map in resBodyMap) {
        songs.add(Song.fromMap(map['song']));
      }
      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, bool>> favSongs(String songId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConstant.serverURL}/song/favorite'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({"song_id": songId}),
      );

      var resBodyMap = jsonDecode(response.body);

      if (response.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }

      return Right(resBodyMap['message']);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<Song>>> searchSongs(String query, String token) async {
    try {
      // Encode the query parameter properly for URL
      final encodedQuery = Uri.encodeQueryComponent(query);

      final url = '${ServerConstant.serverURL}/song/search?query=$encodedQuery';
      print('Making request to: $url'); // Debug log

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      // Debug logging to see what we're getting back
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      // Check for empty response
      if (response.body.isEmpty) {
        return Left(AppFailure('Empty response from server'));
      }

      // Print first few characters of response for debugging
      print('Response preview: ${response.body.substring(0, min(100, response.body.length))}');

      // Try to decode the JSON response safely
      dynamic resBodyMap;
      try {
        resBodyMap = jsonDecode(response.body);
      } catch (e) {
        // If we can't decode the JSON, return the specific error
        return Left(AppFailure('Invalid response format: ${e.toString()}. Response: ${response.body.substring(0, min(100, response.body.length))}...'));
      }

      // Handle error responses
      if (response.statusCode != 200) {
        // Check response type more safely
        if (resBodyMap is Map<String, dynamic> && resBodyMap.containsKey('detail')) {
          return Left(AppFailure(resBodyMap['detail']));
        } else {
          return Left(AppFailure('Error ${response.statusCode}: Could not process server response'));
        }
      }

      // Check if response is a List
      if (resBodyMap is! List) {
        return Left(AppFailure('Expected list of songs but got ${resBodyMap.runtimeType}'));
      }

      // Convert items with safer approach
      List<Song> songs = [];
      for (final item in resBodyMap) {
        try {
          if (item is Map<String, dynamic>) {
            songs.add(Song.fromMap(item));
          } else {
            print('Skipping invalid song item: $item');
          }
        } catch (e) {
          print('Error parsing song: $e');
          // Continue processing other songs even if one fails
        }
      }

      return Right(songs);
    } on SocketException {
      return Left(AppFailure('Network error: Could not connect to server'));
    } on TimeoutException {
      return Left(AppFailure('Request timed out'));
    } catch (e) {
      print('Search error: $e');
      return Left(AppFailure('Search failed: ${e.toString()}'));
    }
  }
}
