// widgets/home_widgets/modern_drawer_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernDrawerWidget extends StatelessWidget {
  final bool isLoggedIn;
  final Map<String, dynamic>? userInfo;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback? onLogoutPressed;
  final VoidCallback? onLoginPressed;
  final String? currentRoute; // เพิ่ม parameter นี้

  const ModernDrawerWidget({
    Key? key,
    required this.isLoggedIn,
    this.userInfo,
    required this.screenWidth,
    required this.screenHeight,
    this.onLogoutPressed,
    this.onLoginPressed,
    this.currentRoute, // เพิ่ม parameter นี้
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
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
            ? 45.0
            : _isShortScreen
            ? 55.0
            : _isTablet
            ? 85.0
            : 75.0;
    final maxTextWidth =
        screenWidth *
        (_isExtraSmallScreen
            ? 0.7
            : _isSmallScreen
            ? 0.65
            : 0.6);

    return Container(
      padding: EdgeInsets.all(_basePadding),
      child: Column(
        children: [
          Container(
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
          SizedBox(height: _smallPadding),
          FittedBox(
            child: Text(
              'ສະບາຍດີ!',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: _titleFontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (isLoggedIn && userInfo != null) ...[
            const SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(maxWidth: maxTextWidth),
              child: Column(
                children: [
                  Builder(builder: (context) {
                    final firstName = userInfo!['first_name']?.toString() ?? '';
                    final lastName = userInfo!['last_name']?.toString() ?? '';
                    final fullName = '$firstName $lastName'.trim();
                    
                    return Text(
                      fullName.isNotEmpty ? fullName : 'ນັກສຶກສາ',
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: _bodyFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                  if (userInfo!['admission_no'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ລະຫັດ: ${userInfo!['admission_no']}',
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: _captionFontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ] else
            Container(
              constraints: BoxConstraints(maxWidth: maxTextWidth),
              child: Text(
                'ຍິນດີຕ້ອນຮັບ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: _bodyFontSize,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerMenu(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _smallPadding),
      child: SingleChildScrollView(
        child: Column(
          children: [
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
            Container(
              margin: EdgeInsets.symmetric(vertical: _smallPadding),
              child: Divider(color: Colors.white.withOpacity(0.3)),
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
            ? 44.0
            : _isSmallScreen
            ? 48.0
            : 52.0;
    final iconSize =
        _isExtraSmallScreen
            ? 16.0
            : _isSmallScreen
            ? 18.0
            : 20.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: _isExtraSmallScreen ? 3 : 5),
      constraints: BoxConstraints(minHeight: itemHeight),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: _smallPadding,
              vertical: _smallPadding * 0.8,
            ),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: iconSize),
                SizedBox(width: _smallPadding),
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
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
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
            ? 40.0
            : _isSmallScreen
            ? 44.0
            : 48.0;

    return Container(
      padding: EdgeInsets.all(_basePadding),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 280, minHeight: buttonHeight),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                isLoggedIn
                    ? onLogoutPressed
                    : () {
                      Navigator.pop(context);
                      onLoginPressed?.call();
                    },
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _smallPadding,
                vertical: _smallPadding * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                    color: Colors.white,
                    size:
                        _isExtraSmallScreen
                            ? 14.0
                            : _isSmallScreen
                            ? 16.0
                            : 18.0,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        isLoggedIn ? 'ອອກຈາກລະບົບ' : 'ເຂົ້າສູ່ລະບົບ',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: _captionFontSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
