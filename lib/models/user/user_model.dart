class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? phone;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'],
    );
  }
}

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
