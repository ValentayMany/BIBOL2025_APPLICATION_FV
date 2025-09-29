// widgets/home_widgets/improved_stats_card_widget.dart
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
    final cardPadding = basePadding * 0.75;
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
              child: _buildStatCard(
                icon: FontAwesomeIcons.graduationCap,
                title: 'ຫຼັກສູດ',
                value: '$coursesCount',
                color: const Color(0xFF07325D),
                cardPadding: cardPadding,
                titleFontSize: titleFontSize,
                captionFontSize: captionFontSize,
                iconSize: iconSize,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.article,
                title: 'ຂ່າວສານ',
                value: '$newsCount+',
                color: const Color(0xFF2E7D32),
                cardPadding: cardPadding,
                titleFontSize: titleFontSize,
                captionFontSize: captionFontSize,
                iconSize: iconSize,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Icons.people,
          title: 'ນັກຮຽນ',
          value: '1000+',
          color: const Color(0xFFE65100),
          cardPadding: cardPadding,
          titleFontSize: titleFontSize,
          captionFontSize: captionFontSize,
          iconSize: iconSize,
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
          child: _buildStatCard(
            icon: FontAwesomeIcons.graduationCap,
            title: 'ຫຼັກສູດ',
            value: '$coursesCount',
            color: const Color(0xFF07325D),
            cardPadding: cardPadding,
            titleFontSize: titleFontSize,
            captionFontSize: captionFontSize,
            iconSize: iconSize,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.article,
            title: 'ຂ່າວສານ',
            value: '$newsCount+',
            color: const Color(0xFF2E7D32),
            cardPadding: cardPadding,
            titleFontSize: titleFontSize,
            captionFontSize: captionFontSize,
            iconSize: iconSize,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            title: 'ນັກຮຽນ',
            value: '1000+',
            color: const Color(0xFFE65100),
            cardPadding: cardPadding,
            titleFontSize: titleFontSize,
            captionFontSize: captionFontSize,
            iconSize: iconSize,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double cardPadding,
    required double titleFontSize,
    required double captionFontSize,
    required double iconSize,
  }) {
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(cardPadding * 0.8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: iconSize, color: color),
          ),
          SizedBox(height: cardPadding * 0.8),
          FittedBox(
            child: Text(
              value,
              style: GoogleFonts.notoSansLao(
                fontSize: titleFontSize * 0.8,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              title,
              style: GoogleFonts.notoSansLao(
                fontSize: captionFontSize,
                color: Colors.grey[600],
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
    if (screenWidth < 320) return 14.0;
    if (screenWidth < 375) return 16.0;
    if (screenWidth < 414) return 18.0;
    if (screenWidth < 600) return 20.0;
    if (screenWidth < 900) return 24.0;
    return 28.0; // Desktop
  }

  double _getCaptionFontSize(double screenWidth) {
    if (screenWidth < 320) return 9.0;
    if (screenWidth < 375) return 10.0;
    if (screenWidth < 414) return 11.0;
    if (screenWidth < 600) return 12.0;
    if (screenWidth < 900) return 13.0;
    return 14.0; // Desktop
  }

  double _getIconSize(double screenWidth) {
    if (screenWidth < 320) return 12.0;
    if (screenWidth < 375) return 14.0;
    if (screenWidth < 414) return 16.0;
    if (screenWidth < 600) return 18.0;
    if (screenWidth < 900) return 22.0;
    return 26.0; // Desktop
  }
}
