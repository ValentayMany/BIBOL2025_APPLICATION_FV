// widgets/home_widgets/header_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback? onLogoutPressed;
  final VoidCallback? onLoginPressed;
  final bool isLoggedIn;
  final Map<String, dynamic>? userInfo;
  final double screenWidth;

  const HeaderWidget({
    Key? key,
    required this.onMenuPressed,
    this.onLogoutPressed,
    this.onLoginPressed,
    required this.isLoggedIn,
    this.userInfo,
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

  final primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_basePadding * 2),
          bottomRight: Radius.circular(_basePadding * 2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF07325D).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(_basePadding),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildHeaderButton(
                      icon: Icons.menu_rounded,
                      onPressed: onMenuPressed,
                    ),
                    const Spacer(),
                    if (isLoggedIn)
                      _buildHeaderButton(
                        icon: Icons.power_settings_new,
                        onPressed: onLogoutPressed ?? () {},
                        tooltip: 'ອອກຈາກລະບົບ',
                      )
                    else
                      _buildLoginButton(),
                  ],
                ),
                SizedBox(height: _smallPadding),
                _buildLogoSection(),
              ],
            ),
          ),
          SizedBox(height: _basePadding),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    final buttonSize =
        _isExtraSmallScreen
            ? 36.0
            : _isSmallScreen
            ? 40.0
            : 44.0;
    final iconSize = buttonSize * 0.5;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(buttonSize * 0.36),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: iconSize),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildLoginButton() {
    final buttonHeight =
        _isExtraSmallScreen
            ? 36.0
            : _isSmallScreen
            ? 40.0
            : 44.0;
    final buttonWidth =
        _isExtraSmallScreen
            ? 90.0
            : _isSmallScreen
            ? 100.0
            : 120.0;

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(buttonHeight * 0.36),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: TextButton(
        onPressed: onLoginPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: _smallPadding),
          minimumSize: Size(buttonWidth, buttonHeight),
        ),
        child: FittedBox(
          child: Text(
            'ເຂົ້າສູ່ລະບົບ',
            style: GoogleFonts.notoSansLao(
              color: Colors.white,
              fontSize: _captionFontSize * 0.9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final logoSize =
            _isExtraSmallScreen
                ? 50.0
                : _isSmallScreen
                ? 60.0
                : _isMediumScreen
                ? 70.0
                : _isTablet
                ? 90.0
                : 80.0;

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
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(logoSize * 0.15),
                    child: Image.asset(
                      'assets/images/LOGO.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: _smallPadding),
                FittedBox(
                  child: Text(
                    'ສະຖາບັນການທະນາຄານ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: _titleFontSize * 1.2,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  child: Text(
                    '🎊ຍິນດີຕ້ອນຮັບ🎊',
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
