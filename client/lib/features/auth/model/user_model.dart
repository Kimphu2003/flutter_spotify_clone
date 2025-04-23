import 'dart:convert';

import 'package:flutter_spotify_clone/core/models/fav_song_model.dart';

class User {
  String name;
  String email;
  String id;
  String token;
  List<FavSongModel> favorites;

  User({
    required this.name,
    required this.email,
    required this.id,
    required this.token,
    required this.favorites,
  });

  User copyWith({String? name, String? email, String? id, String? token, List<FavSongModel>? favorites}) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      id: id ?? this.id,
      token: token ?? this.token,
      favorites: favorites ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "name": name,
      "email": email,
      "id": id,
      "token": token,
      "favorites": favorites.map((x) => x.toMap()).toList(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      id: map['id'] ?? '',
      token: map['token'] ?? '',
      favorites: List<FavSongModel>.from(
        (map['favorites'] ?? []).map(
          (x) => FavSongModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'User(name: $name, email: $email, id: $id)';

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.name == name && other.email == email && other.id == id;
  }

  @override
  int get hashcode => name.hashCode ^ email.hashCode ^ id.hashCode;
}
