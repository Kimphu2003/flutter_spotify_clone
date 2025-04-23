import 'dart:convert';

class FavSongModel {
  String id;
  String song_id;
  String user_id;

  FavSongModel({
    required this.id,
    required this.song_id,
    required this.user_id,
  });

  FavSongModel copyWith({String? id, String? song_id, String? user_id}) {
    return FavSongModel(
      id: id ?? this.id,
      song_id: song_id ?? this.song_id,
      user_id: user_id ?? this.user_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "song_id": song_id,
      "user_id": user_id,
    };
  }

  factory FavSongModel.fromMap(Map<String, dynamic> map) {
    return FavSongModel(
      id: map['id'] ?? '',
      song_id: map['song_id'] ?? '',
      user_id: map['user_id'] ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FavSongModel.fromJson(String source) =>
      FavSongModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'FavSongModel(song_id: $song_id, user_id: $user_id, id: $id)';

  @override
  bool operator ==(covariant FavSongModel other) {
    if (identical(this, other)) return true;

    return other.song_id == song_id &&
        other.user_id == user_id &&
        other.id == id;
  }

  @override
  int get hashcode => song_id.hashCode ^ user_id.hashCode ^ id.hashCode;
}
