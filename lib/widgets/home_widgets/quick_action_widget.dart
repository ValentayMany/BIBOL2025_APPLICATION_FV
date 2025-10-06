// widgets/home_widgets/quick_action_widget.dart - Premium Design
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionWidget extends StatelessWidget {
  final double screenWidth;

  const QuickActionWidget({Key? key, required this.screenWidth})
    : super(key: key);

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

  double get _titleFontSize {
    if (_isExtraSmallScreen) return 18.0;
    if (_isSmallScreen) return 20.0;
    if (_isMediumScreen) return 24.0;
    if (_isTablet) return 30.0;
    return 26.0;
  }

  double get _bodyFontSize {
    if (_isExtraSmallScreen) return 13.0;
    if (_isSmallScreen) return 14.0;
    if (_isMediumScreen) return 15.0;
    if (_isTablet) return 17.0;
    return 16.0;
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
      margin: EdgeInsets.all(_basePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: _titleFontSize * 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: _basePadding * 0.6),
              Text(
                'ການດຳເນີນງານດ່ວນ',
                style: GoogleFonts.notoSansLao(
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF07325D),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _isExtraSmallScreen || _isSmallScreen
              ? Column(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: _buildQuickActionCard(
                            icon: Icons.phone_rounded,
                            title: 'ຕິດຕໍ່ເຮົາ',
                            subtitle: 'ສອບຖາມຂໍ້ມູນເພີ່ມເຕີມ',
                            gradientColors: [
                              Color(0xFF10B981),
                              Color(0xFF059669),
                            ],
                            onTap: () {},
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 450),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: _buildQuickActionCard(
                            icon: Icons.school_rounded,
                            title: 'ສະໝັກຮຽນ',
                            subtitle: 'ລົງທະບຽນຮຽນ',
                            gradientColors: [
                              Color(0xFFF59E0B),
                              Color(0xFFD97706),
                            ],
                            onTap: () {},
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
                            child: _buildQuickActionCard(
                              icon: Icons.phone_rounded,
                              title: 'ຕິດຕໍ່ເຮົາ',
                              subtitle: 'ສອບຖາມຂໍ້ມູນເພີ່ມເຕີມ',
                              gradientColors: [
                                Color(0xFF10B981),
                                Color(0xFF059669),
                              ],
                              onTap: () {},
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
                            child: _buildQuickActionCard(
                              icon: Icons.school_rounded,
                              title: 'ສະໝັກຮຽນ',
                              subtitle: 'ລົງທະບຽນຮຽນ',
                              gradientColors: [
                                Color(0xFFF59E0B),
                                Color(0xFFD97706),
                              ],
                              onTap: () {},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradientColors.first.withOpacity(0.2),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(
              _isExtraSmallScreen ? 14.0 : _basePadding * 1.2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        _isExtraSmallScreen ? 10.0 : _basePadding * 0.8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors.first.withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size:
                            _isExtraSmallScreen
                                ? 22.0
                                : _isSmallScreen
                                ? 24.0
                                : 28.0,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: gradientColors.first.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: _captionFontSize * 1.2,
                        color: gradientColors.first,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: _isExtraSmallScreen ? 12.0 : _basePadding),
                FittedBox(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize * 1.1,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF07325D),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansLao(
                    fontSize: _captionFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
