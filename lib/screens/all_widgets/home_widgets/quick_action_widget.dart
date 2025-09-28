// widgets/home_widgets/quick_action_widget.dart
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
    if (_isExtraSmallScreen) return 16.0;
    if (_isSmallScreen) return 18.0;
    if (_isMediumScreen) return 22.0;
    if (_isTablet) return 28.0;
    return 24.0;
  }

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
    return Container(
      margin: EdgeInsets.all(_basePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ການດຳເນີນງານດ່ວນ',
            style: GoogleFonts.notoSansLao(
              fontSize: _titleFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF07325D),
            ),
          ),
          const SizedBox(height: 16),
          _isExtraSmallScreen || _isSmallScreen
              ? Column(
                children: [
                  _buildQuickActionCard(
                    icon: Icons.phone,
                    title: 'ຕິດຕໍ່ເຮົາ',
                    subtitle: 'ສອບຖາມຂໍ້ມູນເພີ່ມເຕີມ',
                    color: const Color(0xFF2E7D32),
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    icon: Icons.school,
                    title: 'ສະໝັກຮຽນ',
                    subtitle: 'ລົງທະບຽນຮຽນ',
                    color: const Color(0xFFE65100),
                    onTap: () {},
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.phone,
                      title: 'ຕິດຕໍ່ເຮົາ',
                      subtitle: 'ສອບຖາມຂໍ້ມູນເພີ່ມເຕີມ',
                      color: const Color(0xFF2E7D32),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.school,
                      title: 'ສະໝັກຮຽນ',
                      subtitle: 'ລົງທະບຽນຮຽນ',
                      color: const Color(0xFFE65100),
                      onTap: () {},
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
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
            padding: EdgeInsets.all(_isExtraSmallScreen ? 10.0 : _basePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    _isExtraSmallScreen ? 6.0 : _smallPadding * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size:
                        _isExtraSmallScreen
                            ? 18.0
                            : _isSmallScreen
                            ? 20.0
                            : 24.0,
                    color: color,
                  ),
                ),
                SizedBox(height: _isExtraSmallScreen ? 6.0 : _smallPadding),
                FittedBox(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansLao(
                    fontSize: _captionFontSize,
                    color: Colors.grey[600],
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
