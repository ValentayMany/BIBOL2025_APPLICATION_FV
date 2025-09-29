// widgets/home_widgets/stats_card_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StatsCardWidget extends StatelessWidget {
  final int coursesCount;
  final int newsCount;
  final double screenWidth;

  const StatsCardWidget({
    Key? key,
    required this.coursesCount,
    required this.newsCount,
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _basePadding, vertical: 10),
      child:
          _isExtraSmallScreen || _isSmallScreen
              ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: FontAwesomeIcons.graduationCap,
                          title: 'ຫຼັກສູດ',
                          value: '$coursesCount',
                          color: const Color(0xFF07325D),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.article,
                          title: 'ຂ່າວສານ',
                          value: '$newsCount+',
                          color: const Color(0xFF2E7D32),
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
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: FontAwesomeIcons.graduationCap,
                      title: 'ຫຼັກສູດ',
                      value: '$coursesCount',
                      color: const Color(0xFF07325D),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.article,
                      title: 'ຂ່າວສານ',
                      value: '$newsCount+',
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people,
                      title: 'ນັກຮຽນ',
                      value: '1000+',
                      color: const Color(0xFFE65100),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final cardPadding = _isExtraSmallScreen ? 8.0 : _basePadding * 0.75;
    final iconSize =
        _isExtraSmallScreen
            ? 14.0
            : _isSmallScreen
            ? 16.0
            : _isTablet
            ? 26.0
            : 22.0;

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
                fontSize: _titleFontSize * 0.8,
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
                fontSize: _captionFontSize,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
