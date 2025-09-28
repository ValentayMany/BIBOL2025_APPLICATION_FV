// lib/widgets/course_widgets/course_detail_app_bar_widget.dart
import 'package:BIBOL/screens/Home/course_detail_page.dart';
import 'package:BIBOL/screens/all_widgets/common/background_pattern_painter.dart';
import 'package:BIBOL/screens/all_widgets/course_widgets/course_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:BIBOL/models/course/course_model.dart';

class CourseDetailAppBarWidget extends StatelessWidget {
  final CourseModel course;

  const CourseDetailAppBarWidget({Key? key, required this.course})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      floating: false,
      pinned: true,
      backgroundColor: Color(0xFF07325D),
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white, Colors.grey[100]!]),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.arrow_back_ios, color: Color(0xFF07325D), size: 20),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[100]!],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.share_outlined,
              color: Color(0xFF07325D),
              size: 20,
            ),
          ),
        ),
        SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF07325D), Color(0xFF0A4A73), Color(0xFF0D5A8A)],
            ),
          ),
          child: Stack(
            children: [
              CustomPaint(
                painter: BackgroundPatternPainter(),
                child: Container(),
              ),
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'course_icon_${course.id}',
                      child: CourseIconWidget(),
                    ),
                    SizedBox(height: 20),
                    Hero(
                      tag: 'course_title_${course.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          course.title,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey[50]!],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        _getCourseTypeFromTitle(course.title),
                        style: GoogleFonts.notoSansLao(
                          fontSize: 13,
                          color: Color(0xFF07325D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCourseTypeFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('ປະລິນຍາໂທ')) return 'ປະລິນຍາໂທ ລະບົບ 2 ປີ';
    if (lowerTitle.contains('ຕໍ່ເນື່ອງ') && lowerTitle.contains('ພາກຄ່ຳ'))
      return 'ຕໍ່ເນື່ອງ ພາກຄ່ຳ ລະບົບ 2 ປີ';
    if (lowerTitle.contains('ຕໍ່ເນື່ອງ'))
      return 'ຕໍ່ເນື່ອງ ພາກປົກກະຕິ ລະບົບ 2 ປີ';
    if (lowerTitle.contains('4 ປີ')) return 'ປະລິນຍາຕີ ລະບົບ 4 ປີ';
    return 'ປະລິນຍາຕີ';
  }
}
