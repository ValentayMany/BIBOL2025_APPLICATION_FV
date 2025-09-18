class CourseModel {
  final int id;
  final String title;
  final String details;
  final String? icon;

  CourseModel({
    required this.id,
    required this.title,
    required this.details,
    this.icon,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      details: json['details'],
      icon: json['icon'],
    );
  }
}
