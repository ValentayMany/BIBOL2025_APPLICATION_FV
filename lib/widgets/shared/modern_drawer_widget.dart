// widgets/shared/modern_drawer_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernDrawerWidget extends StatelessWidget {
  final bool isLoggedIn;
  final Map<String, dynamic>? userInfo;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback? onLogoutPressed;
  final VoidCallback? onLoginPressed;
  final String? currentRoute;

  const ModernDrawerWidget({
    Key? key,
    required this.isLoggedIn,
    this.userInfo,
    required this.screenWidth,
    required this.screenHeight,
    this.onLogoutPressed,
    this.onLoginPressed,
    this.currentRoute,
  }) : super(key: key);

  // Responsive helper methods
  bool get _isExtraSmallScreen => screenWidth < 320;
  bool get _isSmallScreen => screenWidth < 375;
  bool get _isShortScreen => screenHeight < 667;
  bool get _isTablet => screenWidth >= 600;

  double get _basePadding {
    if (_isExtraSmallScreen) return 10.0;
    if (_isSmallScreen) return 12.0;
    if (_isTablet) return 24.0;
    return 20.0;
  }

  double get _smallPadding => _basePadding * 0.75;

  double get _titleFontSize {
    if (_isExtraSmallScreen) return 16.0;
    if (_isSmallScreen) return 18.0;
    if (_isTablet) return 28.0;
    return 24.0;
  }

  double get _bodyFontSize {
    if (_isExtraSmallScreen) return 12.0;
    if (_isSmallScreen) return 13.0;
    if (_isTablet) return 16.0;
    return 15.0;
  }

  double get _captionFontSize {
    if (_isExtraSmallScreen) return 10.0;
    if (_isSmallScreen) return 11.0;
    if (_isTablet) return 14.0;
    return 13.0;
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth =
        screenWidth *
        (_isExtraSmallScreen
            ? 0.9
            : _isSmallScreen
            ? 0.85
            : 0.8);

    return Drawer(
      backgroundColor: Colors.transparent,
      width: drawerWidth,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF07325D),
              Color(0xFF0A4A85),
              Color(0xFF0D5299),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(context),
              Expanded(child: _buildDrawerMenu(context)),
              _buildDrawerFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final avatarSize =
        _isExtraSmallScreen
            ? 50.0
            : _isShortScreen
            ? 60.0
            : _isTablet
            ? 90.0
            : 75.0;
    final maxTextWidth =
        screenWidth *
        (_isExtraSmallScreen
            ? 0.7
            : _isSmallScreen
            ? 0.65
            : 0.6);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_basePadding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar with border
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isLoggedIn
                    ? Icons.account_circle_rounded
                    : Icons.menu_book_rounded,
                color: const Color(0xFF07325D),
                size: avatarSize * 0.6,
              ),
            ),
          ),
          SizedBox(height: _basePadding),
          
          // Greeting with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ສະບາຍດີ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.white,
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '👋',
                style: TextStyle(fontSize: _titleFontSize * 0.9),
              ),
            ],
          ),
          
          SizedBox(height: _smallPadding),
          
          if (isLoggedIn && userInfo != null) ...[
            // User info card
            Container(
              constraints: BoxConstraints(maxWidth: maxTextWidth),
              padding: EdgeInsets.symmetric(
                horizontal: _basePadding,
                vertical: _smallPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Name
                  Text(
                    "${userInfo!['first_name'] ?? ''} ${userInfo!['last_name'] ?? ''}"
                        .trim(),
                    style: GoogleFonts.notoSansLao(
                      color: Colors.white,
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Student ID
                  if (userInfo!['student_id'] != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          color: Colors.white.withOpacity(0.7),
                          size: _captionFontSize + 2,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${userInfo!['student_id']}',
                          style: GoogleFonts.notoSansLao(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: _captionFontSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            Container(
              constraints: BoxConstraints(maxWidth: maxTextWidth),
              child: Column(
                children: [
                  Text(
                    'ສະຖາບັນການທະນາຄານ',
                    style: GoogleFonts.notoSansLao(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ຍິນດີຕ້ອນຮັບທຸກທ່ານ',
                    style: GoogleFonts.notoSansLao(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: _captionFontSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerMenu(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _basePadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu section
            Padding(
              padding: EdgeInsets.only(
                left: _smallPadding,
                bottom: _smallPadding,
                top: _smallPadding,
              ),
              child: Text(
                'ເມນູຫຼັກ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: _captionFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home_rounded,
              title: 'ໜ້າຫຼັກ',
              isSelected: currentRoute == '/home' || currentRoute == null,
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/home' && currentRoute != null) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
            _buildDrawerItem(
              icon: Icons.newspaper_rounded,
              title: 'ຂ່າວສານ',
              isSelected: currentRoute == '/news',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/news') {
                  Navigator.pushReplacementNamed(context, '/news');
                }
              },
            ),
            _buildDrawerItem(
              icon: Icons.photo_library_rounded,
              title: 'ຮູບພາບ',
              isSelected: currentRoute == '/gallery',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/gallery') {
                  Navigator.pushReplacementNamed(context, '/gallery');
                }
              },
            ),
            _buildDrawerItem(
              icon: Icons.info_rounded,
              title: 'ກ່ຽວກັບ',
              isSelected: currentRoute == '/about',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/about') {
                  Navigator.pushReplacementNamed(context, '/about');
                }
              },
            ),
            if (isLoggedIn)
              _buildDrawerItem(
                icon: Icons.person_rounded,
                title: 'ໂປຣໄຟລ໌',
                isSelected: currentRoute == '/profile',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/profile') {
                    Navigator.pushReplacementNamed(context, '/profile');
                  }
                },
              ),
            
            // Divider with gradient
            Container(
              margin: EdgeInsets.symmetric(vertical: _basePadding),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            
            // Other section
            Padding(
              padding: EdgeInsets.only(
                left: _smallPadding,
                bottom: _smallPadding,
              ),
              child: Text(
                'ອື່ນໆ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: _captionFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.settings_rounded,
              title: 'ຕັ້ງຄ່າ',
              isSelected: false,
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.help_rounded,
              title: 'ຊ່ວຍເຫຼືອ',
              isSelected: false,
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: _basePadding),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final itemHeight =
        _isExtraSmallScreen
            ? 48.0
            : _isSmallScreen
            ? 52.0
            : 56.0;
    final iconSize =
        _isExtraSmallScreen
            ? 18.0
            : _isSmallScreen
            ? 20.0
            : 22.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: _isExtraSmallScreen ? 4 : 6),
      constraints: BoxConstraints(minHeight: itemHeight),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: _basePadding,
              vertical: _smallPadding,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.1),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.4)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Icon with background
                Container(
                  padding: EdgeInsets.all(_isExtraSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: _basePadding),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSansLao(
                      color: Colors.white,
                      fontSize: _bodyFontSize,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: iconSize,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    final buttonHeight =
        _isExtraSmallScreen
            ? 44.0
            : _isSmallScreen
            ? 48.0
            : 52.0;

    return Container(
      padding: EdgeInsets.all(_basePadding * 1.2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App version or info
          Padding(
            padding: EdgeInsets.only(bottom: _smallPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance,
                  color: Colors.white.withOpacity(0.5),
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  'Banking Institute',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: _captionFontSize - 1,
                  ),
                ),
              ],
            ),
          ),
          // Login/Logout button
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 300, minHeight: buttonHeight),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoggedIn
                    ? onLogoutPressed
                    : () {
                        Navigator.pop(context);
                        onLoginPressed?.call();
                      },
                borderRadius: BorderRadius.circular(28),
                splashColor: Colors.white.withOpacity(0.1),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _basePadding,
                    vertical: _smallPadding,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLoggedIn
                              ? Icons.logout_rounded
                              : Icons.login_rounded,
                          color: Colors.white,
                          size: _isExtraSmallScreen ? 16.0 : 18.0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isLoggedIn ? 'ອອກຈາກລະບົບ' : 'ເຂົ້າສູ່ລະບົບ',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: _bodyFontSize,
                        ),
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
