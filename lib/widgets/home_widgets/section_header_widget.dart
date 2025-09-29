// widgets/home_widgets/section_header_widget.dart
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
    if (_isExtraSmallScreen) return 16.0;
    if (_isSmallScreen) return 18.0;
    if (_isMediumScreen) return 22.0;
    if (_isTablet) return 28.0;
    return 24.0;
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _basePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSansLao(
                      fontSize: _titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF07325D),
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: GoogleFonts.notoSansLao(
                      fontSize: _captionFontSize,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (onActionPressed != null && actionText != null)
            TextButton(
              onPressed: onActionPressed,
              child: Text(
                actionText!,
                style: GoogleFonts.notoSansLao(
                  color: const Color(0xFF07325D),
                  fontWeight: FontWeight.w600,
                  fontSize: _captionFontSize,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
