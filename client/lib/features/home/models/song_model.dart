import 'dart:convert';
import 'dart:core';

// ignore_for_file: non_constant_identifier_names

class Song {
  String id;
  String song_name;
  String song_url;
  String artist;
  String thumbnail_url;
  String hex_code;

  Song({
    required this.id,
    required this.song_name,
    required this.song_url,
    required this.artist,
    required this.thumbnail_url,
    required this.hex_code,
  });

  Song copyWith({
    String? id,
    String? song_name,
    String? song_url,
    String? token,
    String? artist,
    String? thumbnail_url,
    String? hex_code,
  }) {
    return Song(
      id: id ?? this.id,
      song_name: song_name ?? this.song_name,
      song_url: song_url ?? this.song_url,
      thumbnail_url: token ?? this.thumbnail_url,
      artist: artist ?? this.artist,
      hex_code: hex_code ?? this.hex_code,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "song_name": song_name,
      "song_url": song_url,
      'thumbnail_url': thumbnail_url,
      'artist': artist,
      "hex_code": hex_code,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? '',
      song_name: map['song_name'] ?? '',
      song_url: map['song_url'] ?? '',
      thumbnail_url: map['thumbnail_url'] ?? '',
      artist: map['artist'] ?? '',
      hex_code: map['hex_code'] ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Song.fromJson(String source) =>
      Song.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Song(song_name: $song_name, song_url: $song_url, id: $id)';

  @override
  bool operator ==(covariant Song other) {
    if (identical(this, other)) return true;

    return other.song_name == song_name &&
        other.song_url == song_url &&
        other.id == id;
  }

  @override
  int get hashcode => song_name.hashCode ^ song_url.hashCode ^ id.hashCode;
}
