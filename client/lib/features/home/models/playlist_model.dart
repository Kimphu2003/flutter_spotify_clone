import 'package:flutter/foundation.dart';
import '../../home/models/song_model.dart';

class Playlist {
  final String id;
  final String name;
  final String description;
  final String userId;
  final List<Song> songs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int song_count;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.songs,
    required this.createdAt,
    required this.updatedAt,
    required this.song_count,
  });

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    List<Song>? songs,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? song_count,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      song_count: song_count ?? this.song_count,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'user_id': userId,
      'songs': songs.map((x) => x.toMap()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'song_count': song_count,
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      // Fixed: Check for both 'songs' and 'song' keys to handle API inconsistencies
      songs: _parseSongs(map),
      createdAt: _parseDateTime(map['created_at']),
      updatedAt: _parseDateTime(map['updated_at']),
      song_count: map['song_count'],
    );
  }

  static List<Song> _parseSongs(Map<String, dynamic> map) {
    final songsData = map['songs'] ?? map['song'];
    if (songsData == null) return [];

    if (songsData is List) {
      return songsData
          .map((songData) {
        try {
          return Song.fromMap(songData as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing song: $e');
          return null;
        }
      })
          .where((song) => song != null)
          .cast<Song>()
          .toList();
    }
    return [];
  }

  // Helper method to parse DateTime with fallback
  static DateTime _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();

    try {
      if (dateStr is String) {
        return DateTime.parse(dateStr);
      }
      return DateTime.now();
    } catch (e) {
      print('Error parsing datetime: $e');
      return DateTime.now();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Playlist &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.userId == userId &&
        listEquals(other.songs, songs) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    description.hashCode ^
    userId.hashCode ^
    songs.hashCode ^
    createdAt.hashCode ^
    updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, description: $description, userId: $userId, songs: ${songs.length}, createdAt: $createdAt, updatedAt: $updatedAt, song_count: $song_count)';
  }
}