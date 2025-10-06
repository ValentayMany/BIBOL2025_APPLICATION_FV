// widgets/home_widgets/stats_card_widget.dart - Premium Design
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _basePadding, vertical: 10),
      child:
          _isExtraSmallScreen || _isSmallScreen
              ? Column(
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
                                  gradientColors: [
                                    Color(0xFF3B82F6),
                                    Color(0xFF2563EB),
                                  ],
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
                                  gradientColors: [
                                    Color(0xFF10B981),
                                    Color(0xFF059669),
                                  ],
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
                            gradientColors: [
                              Color(0xFFF59E0B),
                              Color(0xFFD97706),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
              : Row(
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
                              gradientColors: [
                                Color(0xFF3B82F6),
                                Color(0xFF2563EB),
                              ],
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
                              gradientColors: [
                                Color(0xFF10B981),
                                Color(0xFF059669),
                              ],
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
                              gradientColors: [
                                Color(0xFFF59E0B),
                                Color(0xFFD97706),
                              ],
                            ),
                          ),
                        );
                      },
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
    required List<Color> gradientColors,
  }) {
    final cardPadding = _isExtraSmallScreen ? 10.0 : _basePadding * 0.9;
    final iconSize =
        _isExtraSmallScreen
            ? 16.0
            : _isSmallScreen
            ? 18.0
            : _isTablet
            ? 28.0
            : 24.0;

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
                fontSize: _titleFontSize * 0.9,
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
                fontSize: _captionFontSize,
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
}
