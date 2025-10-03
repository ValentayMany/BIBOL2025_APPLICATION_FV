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
    return 18.0;
  }

  double get _smallPadding => _basePadding * 0.75;

  double get _titleFontSize {
    if (_isExtraSmallScreen) return 18.0;
    if (_isSmallScreen) return 20.0;
    if (_isTablet) return 28.0;
    return 24.0;
  }

  double get _bodyFontSize {
    if (_isExtraSmallScreen) return 13.0;
    if (_isSmallScreen) return 14.0;
    if (_isTablet) return 17.0;
    return 15.0;
  }

  double get _captionFontSize {
    if (_isExtraSmallScreen) return 11.0;
    if (_isSmallScreen) return 12.0;
    if (_isTablet) return 15.0;
    return 13.0;
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth =
        screenWidth *
        (_isExtraSmallScreen
            ? 0.88
            : _isSmallScreen
            ? 0.82
            : 0.78);

    return Drawer(
      backgroundColor: Colors.transparent,
      width: drawerWidth,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF06304F),
              Color(0xFF07325D),
              Color(0xFF0A4A85),
              Color(0xFF0D5299),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
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
            ? 55.0
            : _isShortScreen
            ? 65.0
            : _isTablet
            ? 95.0
            : 80.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_basePadding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo/Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              Container(
                width: avatarSize + 8,
                height: avatarSize + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Avatar
              Container(
                width: avatarSize,
                height: avatarSize,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.95),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    isLoggedIn
                        ? Icons.account_circle_rounded
                        : Icons.account_balance_rounded,
                    color: const Color(0xFF07325D),
                    size: avatarSize * 0.55,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: _basePadding),
          
          // Welcome message
          if (isLoggedIn && userInfo != null) ...[
            Text(
              'ຍິນດີຕ້ອນຮັບ',
              style: GoogleFonts.notoSansLao(
                color: Colors.white.withOpacity(0.7),
                fontSize: _captionFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: BoxConstraints(maxWidth: screenWidth * 0.65),
              child: Text(
                "${userInfo!['first_name'] ?? ''} ${userInfo!['last_name'] ?? ''}"
                    .trim(),
                style: GoogleFonts.notoSansLao(
                  color: Colors.white,
                  fontSize: _titleFontSize * 0.85,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (userInfo!['student_id'] != null || 
                userInfo!['admission_no'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.badge,
                      color: Colors.white.withOpacity(0.9),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      userInfo!['student_id']?.toString() ?? 
                          userInfo!['admission_no']?.toString() ?? '',
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: _captionFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            Text(
              'ສະຖາບັນການທະນາຄານ',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: _titleFontSize * 0.9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🎓 ລະບົບການສຶກສາ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: _captionFontSize,
                  fontWeight: FontWeight.w500,
                ),
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
            // Main Menu Section
            SizedBox(height: _smallPadding),
            _buildSectionLabel('ເມນູຫຼັກ'),
            SizedBox(height: _smallPadding),
            
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
              title: 'ຄັງຮູບພາບ',
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
              title: 'ກ່ຽວກັບພວກເຮົາ',
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
                title: 'ໂປຣໄຟລ໌ຂອງຂ້ອຍ',
                isSelected: currentRoute == '/profile',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/profile') {
                    Navigator.pushReplacementNamed(context, '/profile');
                  }
                },
              ),
            
            // Divider
            Container(
              margin: EdgeInsets.symmetric(vertical: _basePadding),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            
            // Other Section
            _buildSectionLabel('ການຕັ້ງຄ່າ'),
            SizedBox(height: _smallPadding),
            
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
            _buildDrawerItem(
              icon: Icons.info_outline_rounded,
              title: 'ກ່ຽວກັບແອັບ',
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
            SizedBox(height: _basePadding),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: _smallPadding),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.notoSansLao(
          color: Colors.white.withOpacity(0.5),
          fontSize: _captionFontSize - 1,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
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
            ? 50.0
            : _isSmallScreen
            ? 54.0
            : 58.0;
    final iconSize =
        _isExtraSmallScreen
            ? 20.0
            : _isSmallScreen
            ? 22.0
            : 24.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: _isExtraSmallScreen ? 4 : 5),
      constraints: BoxConstraints(minHeight: itemHeight),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withOpacity(0.15),
          highlightColor: Colors.white.withOpacity(0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
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
                        Colors.white.withOpacity(0.28),
                        Colors.white.withOpacity(0.12),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.45)
                    : Colors.transparent,
                width: isSelected ? 1.5 : 0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: EdgeInsets.all(_isExtraSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
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
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
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
            ? 48.0
            : _isSmallScreen
            ? 52.0
            : 56.0;

    return Container(
      padding: EdgeInsets.all(_basePadding * 1.3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.15),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Institution info
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _basePadding,
              vertical: _smallPadding * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance,
                  color: Colors.white.withOpacity(0.6),
                  size: 16,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'ສະຖາບັນການທະນາຄານ',
                    style: GoogleFonts.notoSansLao(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: _captionFontSize - 1,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: _basePadding),
          
          // Login/Logout button
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: buttonHeight),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoggedIn
                    ? onLogoutPressed
                    : () {
                        Navigator.pop(context);
                        onLoginPressed?.call();
                      },
                borderRadius: BorderRadius.circular(30),
                splashColor: Colors.white.withOpacity(0.15),
                highlightColor: Colors.white.withOpacity(0.08),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _basePadding * 1.2,
                    vertical: _basePadding * 0.7,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.28),
                        Colors.white.withOpacity(0.18),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
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
                      const SizedBox(width: 12),
                      Text(
                        isLoggedIn ? 'ອອກຈາກລະບົບ' : 'ເຂົ້າສູ່ລະບົບ',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: _bodyFontSize,
                          letterSpacing: 0.3,
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.account_balance, color: Color(0xFF07325D)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'ກ່ຽວກັບແອັບ',
                style: GoogleFonts.notoSansLao(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ສະຖາບັນການທະນາຄານ',
              style: GoogleFonts.notoSansLao(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ລະບົບການສຶກສາອອນລາຍ',
              style: GoogleFonts.notoSansLao(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.notoSansLao(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ປິດ',
              style: GoogleFonts.notoSansLao(
                color: Color(0xFF07325D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
