// lib/widgets/course_widgets/course_details_section_widget.dart
import 'package:BIBOL/widgets/course_widgets/course_detail_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:BIBOL/models/course/course_model.dart';

class CourseDetailsSectionWidget extends StatelessWidget {
  final CourseModel course;

  const CourseDetailsSectionWidget({Key? key, required this.course})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          CourseDetailCardWidget(
            icon: Icons.access_time,
            title: 'ໄລຍະເວລາການສຶກສາ',
            content: _getCourseDuration(),
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          ),
          SizedBox(height: 16),
          CourseDetailCardWidget(
            icon: Icons.schedule,
            title: 'ລະບົບການສຶກສາ',
            content: _getCourseSystem(),
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          ),
          SizedBox(height: 16),
          CourseDetailCardWidget(
            icon: Icons.school,
            title: 'ລະດັບການສຶກສາ',
            content: _getCourseLevel(),
            colors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
          ),
        ],
      ),
    );
  }

  String _getCourseDuration() {
    final title = course.title.toLowerCase();
    if (title.contains('4 ປີ')) return '4 ປີ (8 ພາກການສຶກສາ)';
    if (title.contains('2 ປີ')) return '2 ປີ (4 ພາກການສຶກສາ)';
    return 'ຕິດຕໍ່ສອບຖາມ';
  }

  String _getCourseSystem() {
    final title = course.title.toLowerCase();
    if (title.contains('ພາກຄ່ຳ')) return 'ພາກຄ່ຳ (Evening Program)';
    if (title.contains('ຕໍ່ເນື່ອງ')) return 'ຕໍ່ເນື່ອງ (Continuing Education)';
    return 'ພາກປົກກະຕິ (Regular Program)';
  }

  String _getCourseLevel() {
    final title = course.title.toLowerCase();
    if (title.contains('ປະລິນຍາໂທ')) return 'ປະລິນຍາໂທ (Master\'s Degree)';
    return 'ປະລິນຍາຕີ (Bachelor\'s Degree)';
  }
}
