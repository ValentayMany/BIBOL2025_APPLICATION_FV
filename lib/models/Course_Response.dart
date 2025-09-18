import 'course_model.dart';

class CourseResponse {
  final String msg;
  final int type;
  final int bannersCount;
  final List<CourseModel> courses;

  CourseResponse({
    required this.msg,
    required this.type,
    required this.bannersCount,
    required this.courses,
  });

  factory CourseResponse.fromJson(Map<String, dynamic> json) {
    return CourseResponse(
      msg: json['msg'],
      type: json['type'],
      bannersCount: json['banners_count'],
      courses:
          (json['banners'] as List)
              .map((item) => CourseModel.fromJson(item))
              .toList(),
    );
  }
}
