// widgets/home_widgets/section_header_widget.dart - Premium Design
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final double screenWidth;

  const SectionHeaderWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.actionText = 'ເບິ່ງທັງຫມົດ',
    this.onActionPressed,
    required this.screenWidth,
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

  double get _titleFontSize {
    if (_isExtraSmallScreen) return 18.0;
    if (_isSmallScreen) return 20.0;
    if (_isMediumScreen) return 24.0;
    if (_isTablet) return 30.0;
    return 26.0;
  }

  double get _captionFontSize {
    if (_isExtraSmallScreen) return 11.0;
    if (_isSmallScreen) return 12.0;
    if (_isMediumScreen) return 13.0;
    if (_isTablet) return 15.0;
    return 14.0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _basePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                // Decorative line
                Container(
                  width: 4,
                  height: _titleFontSize * 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF07325D),
                        Color(0xFF0A4A85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: _basePadding * 0.6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: GoogleFonts.notoSansLao(
                            fontSize: _titleFontSize,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF07325D),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: GoogleFonts.notoSansLao(
                            fontSize: _captionFontSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onActionPressed != null && actionText != null)
            Container(
              margin: EdgeInsets.only(left: _basePadding * 0.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF07325D).withOpacity(0.1),
                    Color(0xFF0A4A85).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFF07325D).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onActionPressed,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _basePadding * 0.8,
                      vertical: _basePadding * 0.4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionText!,
                          style: GoogleFonts.notoSansLao(
                            color: const Color(0xFF07325D),
                            fontWeight: FontWeight.w700,
                            fontSize: _captionFontSize,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: const Color(0xFF07325D),
                          size: _captionFontSize,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
