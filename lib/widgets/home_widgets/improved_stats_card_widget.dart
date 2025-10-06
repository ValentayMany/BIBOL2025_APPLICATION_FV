// widgets/home_widgets/improved_stats_card_widget.dart - Premium Design
// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ImprovedStatsCardWidget extends StatelessWidget {
  final int coursesCount;
  final int newsCount;

  const ImprovedStatsCardWidget({
    Key? key,
    required this.coursesCount,
    required this.newsCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Enhanced responsive breakpoints
    final isExtraSmall = screenWidth < 320;
    final isSmall = screenWidth < 375;
    final isMedium = screenWidth < 414;
    final isLarge = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    // Height considerations
    final isShortScreen = screenHeight < 667;
    final isLandscape = screenWidth > screenHeight;

    // Responsive values
    final basePadding = _getBasePadding(screenWidth);
    final titleFontSize = _getTitleFontSize(screenWidth);
    final captionFontSize = _getCaptionFontSize(screenWidth);
    final cardPadding = basePadding * 0.9;
    final iconSize = _getIconSize(screenWidth);

    // Layout decision
    final useVerticalLayout =
        isExtraSmall || isSmall || (isShortScreen && !isLandscape);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Constrain content width for larger screens
        final maxWidth =
            isTablet
                ? 600.0
                : isDesktop
                ? 800.0
                : double.infinity;

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            margin: EdgeInsets.symmetric(
              horizontal: basePadding,
              vertical: basePadding * 0.5,
            ),
            child:
                useVerticalLayout
                    ? _buildVerticalLayout(
                      cardPadding: cardPadding,
                      titleFontSize: titleFontSize,
                      captionFontSize: captionFontSize,
                      iconSize: iconSize,
                    )
                    : _buildHorizontalLayout(
                      cardPadding: cardPadding,
                      titleFontSize: titleFontSize,
                      captionFontSize: captionFontSize,
                      iconSize: iconSize,
                    ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalLayout({
    required double cardPadding,
    required double titleFontSize,
    required double captionFontSize,
    required double iconSize,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: _buildStatCard(
                        icon: FontAwesomeIcons.graduationCap,
                        title: 'ຫຼັກສູດ',
                        value: '$coursesCount',
                        gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        cardPadding: cardPadding,
                        titleFontSize: titleFontSize,
                        captionFontSize: captionFontSize,
                        iconSize: iconSize,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 450),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: _buildStatCard(
                        icon: Icons.newspaper_rounded,
                        title: 'ຂ່າວສານ',
                        value: '$newsCount+',
                        gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
                        cardPadding: cardPadding,
                        titleFontSize: titleFontSize,
                        captionFontSize: captionFontSize,
                        iconSize: iconSize,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 500),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: _buildStatCard(
                  icon: Icons.people_rounded,
                  title: 'ນັກຮຽນ',
                  value: '1000+',
                  gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  cardPadding: cardPadding,
                  titleFontSize: titleFontSize,
                  captionFontSize: captionFontSize,
                  iconSize: iconSize,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout({
    required double cardPadding,
    required double titleFontSize,
    required double captionFontSize,
    required double iconSize,
  }) {
    return Row(
      children: [
        Expanded(
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: _buildStatCard(
                    icon: FontAwesomeIcons.graduationCap,
                    title: 'ຫຼັກສູດ',
                    value: '$coursesCount',
                    gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    cardPadding: cardPadding,
                    titleFontSize: titleFontSize,
                    captionFontSize: captionFontSize,
                    iconSize: iconSize,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 450),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: _buildStatCard(
                    icon: Icons.newspaper_rounded,
                    title: 'ຂ່າວສານ',
                    value: '$newsCount+',
                    gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
                    cardPadding: cardPadding,
                    titleFontSize: titleFontSize,
                    captionFontSize: captionFontSize,
                    iconSize: iconSize,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: _buildStatCard(
                    icon: Icons.people_rounded,
                    title: 'ນັກຮຽນ',
                    value: '1000+',
                    gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    cardPadding: cardPadding,
                    titleFontSize: titleFontSize,
                    captionFontSize: captionFontSize,
                    iconSize: iconSize,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required List<Color> gradientColors,
    required double cardPadding,
    required double titleFontSize,
    required double captionFontSize,
    required double iconSize,
  }) {
    return Container(
      padding: EdgeInsets.all(cardPadding * 1.2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradientColors.first.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, size: iconSize * 1.3, color: Colors.white),
          ),
          SizedBox(height: cardPadding),
          FittedBox(
            child: Text(
              value,
              style: GoogleFonts.notoSansLao(
                fontSize: titleFontSize * 0.9,
                fontWeight: FontWeight.w900,
                color: gradientColors.first,
              ),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              title,
              style: GoogleFonts.notoSansLao(
                fontSize: captionFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  double _getBasePadding(double screenWidth) {
    if (screenWidth < 320) return 8.0;
    if (screenWidth < 375) return 10.0;
    if (screenWidth < 414) return 12.0;
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 900) return 20.0;
    return 24.0; // Desktop
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 320) return 16.0;
    if (screenWidth < 375) return 18.0;
    if (screenWidth < 414) return 20.0;
    if (screenWidth < 600) return 22.0;
    if (screenWidth < 900) return 26.0;
    return 30.0; // Desktop
  }

  double _getCaptionFontSize(double screenWidth) {
    if (screenWidth < 320) return 10.0;
    if (screenWidth < 375) return 11.0;
    if (screenWidth < 414) return 12.0;
    if (screenWidth < 600) return 13.0;
    if (screenWidth < 900) return 14.0;
    return 15.0; // Desktop
  }

  double _getIconSize(double screenWidth) {
    if (screenWidth < 320) return 14.0;
    if (screenWidth < 375) return 16.0;
    if (screenWidth < 414) return 18.0;
    if (screenWidth < 600) return 20.0;
    if (screenWidth < 900) return 24.0;
    return 28.0; // Desktop
  }
}
