class JoinedCategory {
  final int id;
  final String title;
  final dynamic icon;
  final dynamic photo;
  final String href;

  JoinedCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.photo,
    required this.href,
  });

  factory JoinedCategory.fromJson(Map<String, dynamic> json) {
    return JoinedCategory(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      icon: json['icon'],
      photo: json['photo'],
      href: json['href'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'photo': photo,
      'href': href,
    };
  }

  JoinedCategory copyWith({
    int? id,
    String? title,
    dynamic icon,
    dynamic photo,
    String? href,
  }) => JoinedCategory(
    id: id ?? this.id,
    title: title ?? this.title,
    icon: icon ?? this.icon,
    photo: photo ?? this.photo,
    href: href ?? this.href,
  );
}
