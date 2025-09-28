// lib/widgets/course_widgets/course_overview_card_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:BIBOL/models/course/course_model.dart';
import 'package:BIBOL/utils/html_utils.dart';

class CourseOverviewCardWidget extends StatelessWidget {
  final CourseModel course;

  const CourseOverviewCardWidget({Key? key, required this.course})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF07325D).withOpacity(0.1),
                        Color(0xFF07325D).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: Color(0xFF07325D),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'ລາຍລະອຽດຫຼັກສູດ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF07325D),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF07325D).withOpacity(0.02),
                    Color(0xFF07325D).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF07325D).withOpacity(0.15)),
              ),
              child: Text(
                HtmlUtils.stripHtmlTags(course.details),
                style: GoogleFonts.notoSansLao(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
