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
    String? iconValue = json['icon'];

    // ถ้าเป็น fa-* ให้เป็น null เพื่อใช้ไอคอน default
    if (iconValue != null && iconValue.startsWith('fa-')) {
      iconValue = null;
    }

    return CourseModel(
      id: json['id'],
      title: json['title'],
      details: json['details'],
      icon: iconValue,
    );
  }
}
