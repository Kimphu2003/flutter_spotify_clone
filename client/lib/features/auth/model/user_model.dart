import 'dart:convert';

class User {
  String name;
  String email;
  String id;
  String token;

  User({required this.name, required this.email, required this.id, required this.token});

  User copyWith({String? name, String? email, String? id, String? token}) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      id: id ?? this.id,
      token: token ?? this.token
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      "name": name,
      "email": email,
      "id": id,
      "token": token
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      id: map['id'] ?? '',
      token: map['token'] ?? ''
    );
  }

  String toJson() => jsonEncode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'User(name: $name, email: $email, id: $id)';

  @override
  bool operator ==(covariant User other) {
    if(identical(this, other)) return true;

    return other.name == name && other.email == email && other.id == id;
  }

  @override
  int get hashcode => name.hashCode ^ email.hashCode ^ id.hashCode;
}
