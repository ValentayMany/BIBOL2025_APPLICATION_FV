class User {
  final int id;
  final String name;
  final String href;

  User({required this.id, required this.name, required this.href});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      href: json['href'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'href': href};
  }

  User copyWith({int? id, String? name, String? href}) =>
      User(id: id ?? this.id, name: name ?? this.name, href: href ?? this.href);
}
