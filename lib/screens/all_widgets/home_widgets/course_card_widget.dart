// widgets/home_widgets/course_card_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:BIBOL/models/course/course_model.dart';

class CourseCardWidget extends StatelessWidget {
  final CourseModel course;
  final double screenWidth;
  final VoidCallback? onTap;

  const CourseCardWidget({
    Key? key,
    required this.course,
    required this.screenWidth,
    this.onTap,
  }) : super(key: key);

  // Responsive helper methods
  bool get _isExtraSmallScreen => screenWidth < 320;
  bool get _isSmallScreen => screenWidth < 375;
  bool get _isMediumScreen => screenWidth < 414;
  bool get _isTablet => screenWidth >= 600;

  double get _basePadding {
    if (_isExtraSmallScreen) return 10.0;
    if (_isSmallScreen) return 12.0;
    if (_isMediumScreen) return 16.0;
    if (_isTablet) return 24.0;
    return 20.0;
  }

  double get _smallPadding => _basePadding * 0.75;

  double get _bodyFontSize {
    if (_isExtraSmallScreen) return 12.0;
    if (_isSmallScreen) return 13.0;
    if (_isMediumScreen) return 14.0;
    if (_isTablet) return 16.0;
    return 15.0;
  }

  double get _captionFontSize {
    if (_isExtraSmallScreen) return 10.0;
    if (_isSmallScreen) return 11.0;
    if (_isMediumScreen) return 12.0;
    if (_isTablet) return 14.0;
    return 13.0;
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight =
        _isExtraSmallScreen
            ? 140.0
            : _isSmallScreen
            ? 160.0
            : 180.0;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(_isExtraSmallScreen ? 10.0 : _smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width:
                          _isExtraSmallScreen
                              ? 28.0
                              : _isSmallScreen
                              ? 32.0
                              : 40.0,
                      height:
                          _isExtraSmallScreen
                              ? 28.0
                              : _isSmallScreen
                              ? 32.0
                              : 40.0,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: _buildCourseIcon(),
                    ),
                    const Spacer(),
                  ],
                ),
                SizedBox(height: _isExtraSmallScreen ? 12.0 : _smallPadding),
                Expanded(
                  flex: 3,
                  child: Text(
                    course.title,
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                    maxLines: _isExtraSmallScreen ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: _isExtraSmallScreen ? 6.0 : _smallPadding * 0.8,
                ),
                Container(
                  width: double.infinity,
                  height:
                      _isExtraSmallScreen
                          ? 28.0
                          : _isSmallScreen
                          ? 32.0
                          : 36.0,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF07325D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: _isExtraSmallScreen ? 10.0 : _captionFontSize,
                        ),
                        const SizedBox(width: 6),
                        FittedBox(
                          child: Text(
                            'ເບິ່ງລາຍລະອຽດ',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _captionFontSize * 0.9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseIcon() {
    final iconSize =
        _isExtraSmallScreen
            ? 12.0
            : _isSmallScreen
            ? 14.0
            : 18.0;

    if (course.icon != null &&
        course.icon!.isNotEmpty &&
        Uri.tryParse(course.icon!) != null &&
        course.icon!.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          course.icon!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              FontAwesomeIcons.graduationCap,
              size: iconSize,
              color: Colors.white,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Icon(
              FontAwesomeIcons.graduationCap,
              size: iconSize,
              color: Colors.white,
            );
          },
        ),
      );
    }

    return Icon(
      FontAwesomeIcons.graduationCap,
      size: iconSize,
      color: Colors.white,
    );
  }
}
