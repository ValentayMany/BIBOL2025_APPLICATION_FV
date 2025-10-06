// widgets/home_widgets/course_card_widget.dart - Premium Design
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
    if (_isExtraSmallScreen) return 13.0;
    if (_isSmallScreen) return 14.0;
    if (_isMediumScreen) return 15.0;
    if (_isTablet) return 17.0;
    return 16.0;
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF07325D).withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF07325D).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(_isExtraSmallScreen ? 12.0 : _basePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width:
                          _isExtraSmallScreen
                              ? 42.0
                              : _isSmallScreen
                              ? 46.0
                              : 50.0,
                      height:
                          _isExtraSmallScreen
                              ? 42.0
                              : _isSmallScreen
                              ? 46.0
                              : 50.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF07325D).withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildCourseIcon(),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _smallPadding * 0.8,
                        vertical: _smallPadding * 0.4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF10B981).withOpacity(0.2),
                            Color(0xFF059669).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF10B981).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Color(0xFF10B981),
                            size: _captionFontSize,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'ແນະນຳ',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _captionFontSize * 0.8,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _isExtraSmallScreen ? 10.0 : _smallPadding),
                Expanded(
                  flex: 3,
                  child: Text(
                    course.title,
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF07325D),
                      height: 1.3,
                      letterSpacing: 0.3,
                    ),
                    maxLines: _isExtraSmallScreen ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: _isExtraSmallScreen ? 8.0 : _smallPadding * 0.9,
                ),
                Container(
                  width: double.infinity,
                  height:
                      _isExtraSmallScreen
                          ? 32.0
                          : _isSmallScreen
                          ? 36.0
                          : 40.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF07325D).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: _captionFontSize * 1.2,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          FittedBox(
                            child: Text(
                              'ເບິ່ງລາຍລະອຽດ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: _captionFontSize,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
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
            ? 18.0
            : _isSmallScreen
            ? 20.0
            : 22.0;

    if (course.icon != null &&
        course.icon!.isNotEmpty &&
        Uri.tryParse(course.icon!) != null &&
        course.icon!.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
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
            return Center(
              child: Icon(
                FontAwesomeIcons.graduationCap,
                size: iconSize,
                color: Colors.white,
              ),
            );
          },
        ),
      );
    }

    return Center(
      child: Icon(
        FontAwesomeIcons.graduationCap,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}
