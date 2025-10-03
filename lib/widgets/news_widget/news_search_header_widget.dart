// widgets/news_widget/news_search_header_widget.dart
// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:ui';
import 'package:BIBOL/widgets/shared/shared_header_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsSearchHeaderWidget extends StatefulWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchQuery;
  final bool hasNotification;

  const NewsSearchHeaderWidget({
    Key? key,
    required this.onMenuPressed,
    this.onNotificationPressed,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchQuery,
    this.hasNotification = true,
  }) : super(key: key);

  @override
  _NewsSearchHeaderWidgetState createState() => _NewsSearchHeaderWidgetState();
}

class _NewsSearchHeaderWidgetState extends State<NewsSearchHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    // Responsive values
    final basePadding = _getBasePadding(screenWidth);
    final smallPadding = basePadding * 0.75;
    final titleFontSize = _getTitleFontSize(screenWidth);
    final subtitleFontSize = _getSubtitleFontSize(screenWidth);
    final bodyFontSize = _getBodyFontSize(screenWidth);
    final iconSize = _getIconSize(screenWidth);
    final logoSize = _getLogoSize(screenWidth);
    final isVerySmallScreen = screenWidth < 320;
    final isTinyScreen = screenWidth < 360;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(basePadding * 2),
          bottomRight: Radius.circular(basePadding * 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF07325D).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(basePadding),
          child: Column(
            children: [
              Row(
                children: [
                  SharedHeaderButton(
                    icon: Icons.menu_rounded,
                    onPressed: widget.onMenuPressed,
                    screenWidth: screenWidth,
                  ),
                  Spacer(),
                  SharedHeaderButton(
                    icon: Icons.notifications_outlined,
                    onPressed: widget.onNotificationPressed ?? () {},
                    hasNotification: widget.hasNotification,
                    screenWidth: screenWidth,
                  ),
                ],
              ),
              SizedBox(height: smallPadding),
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: Column(
                        children: [
                          Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(smallPadding),
                              child: Image.asset(
                                'assets/images/LOGO.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          FittedBox(
                            child: Text(
                              'ຂ່າວສານ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              'ສະຖາບັນການທະນາຄານ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: subtitleFontSize,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              _buildSearchSection(
                screenWidth,
                basePadding,
                smallPadding,
                bodyFontSize,
                iconSize,
                isVerySmallScreen,
                isTinyScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(
    double screenWidth,
    double basePadding,
    double smallPadding,
    double bodyFontSize,
    double iconSize,
    bool isVerySmallScreen,
    bool isTinyScreen,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 600,
        minHeight: isVerySmallScreen ? 45 : 55,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: widget.searchController,
              onChanged: widget.onSearchChanged,
              style: GoogleFonts.notoSansLao(fontSize: bodyFontSize),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText:
                    isVerySmallScreen
                        ? 'ຄົ້ນຫາ...'
                        : isTinyScreen
                        ? 'ຄົ້ນຫາຂ່າວ...'
                        : 'ຄົ້ນຫາຂ່າວທີ່ສົນໃຈ...',
                hintStyle: GoogleFonts.notoSansLao(
                  color: Colors.grey[500],
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Container(
                  padding: EdgeInsets.all(smallPadding),
                  child: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF07325D),
                    size: iconSize * 1.2,
                  ),
                ),
                suffixIcon:
                    widget.searchQuery.isNotEmpty
                        ? Container(
                          padding: EdgeInsets.all(8),
                          child: IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.grey[600],
                                size: iconSize * 0.8,
                              ),
                            ),
                            onPressed: () {
                              widget.searchController.clear();
                              widget.onSearchChanged('');
                            },
                          ),
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: basePadding,
                  vertical: basePadding * 0.9,
                ),
                isDense: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getBasePadding(double screenWidth) {
    if (screenWidth < 320) return 8.0;
    if (screenWidth < 360) return 12.0;
    if (screenWidth < 400) return 16.0;
    if (screenWidth < 480) return 18.0;
    if (screenWidth < 600) return 20.0;
    return 24.0;
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 320) return 18.0;
    if (screenWidth < 360) return 20.0;
    if (screenWidth < 400) return 22.0;
    if (screenWidth < 480) return 24.0;
    return 26.0;
  }

  double _getSubtitleFontSize(double screenWidth) {
    if (screenWidth < 320) return 10.0;
    if (screenWidth < 360) return 11.0;
    if (screenWidth < 400) return 12.0;
    if (screenWidth < 480) return 13.0;
    return 14.0;
  }

  double _getBodyFontSize(double screenWidth) {
    if (screenWidth < 320) return 11.0;
    if (screenWidth < 360) return 12.0;
    if (screenWidth < 400) return 13.0;
    if (screenWidth < 480) return 14.0;
    return 15.0;
  }

  double _getIconSize(double screenWidth) {
    if (screenWidth < 320) return 16.0;
    if (screenWidth < 360) return 18.0;
    if (screenWidth < 400) return 20.0;
    if (screenWidth < 480) return 22.0;
    return 24.0;
  }

  double _getLogoSize(double screenWidth) {
    if (screenWidth < 320) return 50.0;
    if (screenWidth < 360) return 60.0;
    if (screenWidth < 400) return 70.0;
    if (screenWidth < 480) return 80.0;
    return 90.0;
  }
}
