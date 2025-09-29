// lib/widgets/course_widgets/course_icon_widget.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CourseIconWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!]),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: Offset(-5, -5),
          ),
        ],
      ),
      child: Icon(
        FontAwesomeIcons.graduationCap,
        size: 45,
        color: Color(0xFF07325D),
      ),
    );
  }
}
