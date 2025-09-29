// lib/widgets/course_widgets/course_detail_card_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseDetailCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final List<Color> colors;

  const CourseDetailCardWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.content,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors[0].withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors.map((c) => c.withOpacity(0.15)).toList(),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colors[0], size: 28),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  content,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors[0],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
