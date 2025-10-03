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
    return 16.0;
  }

  double get _smallPadding => _basePadding * 0.75;

  double get _titleFontSize {
    if (_isExtraSmallScreen) return 16.0;
    if (_isSmallScreen) return 18.0;
    if (_isTablet) return 24.0;
    return 20.0;
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
    final drawerWidth = screenWidth *
        (_isExtraSmallScreen
            ? 0.85
            : _isSmallScreen
                ? 0.8
                : 0.75);

    return Drawer(
      backgroundColor: Colors.white,
      width: drawerWidth,
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(child: _buildDrawerMenu(context)),
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final avatarSize = _isExtraSmallScreen
        ? 55.0
        : _isShortScreen
            ? 65.0
            : _isTablet
                ? 90.0
                : 75.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_basePadding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF07325D),
            Color(0xFF0A4A85),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Avatar
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isLoggedIn ? Icons.person : Icons.menu_book,
                color: Color(0xFF07325D),
                size: avatarSize * 0.5,
              ),
            ),
            SizedBox(height: _basePadding),

            // User Info
            if (isLoggedIn && userInfo != null) ...[
              Text(
                "${userInfo!['first_name'] ?? ''} ${userInfo!['last_name'] ?? ''}"
                    .trim(),
                style: GoogleFonts.notoSansLao(
                  color: Colors.white,
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (userInfo!['student_id'] != null) ...[
                SizedBox(height: 6),
                Text(
                  'ລະຫັດ: ${userInfo!['student_id']}',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: _captionFontSize,
                  ),
                ),
              ],
            ] else ...[
              Text(
                'ສະຖາບັນການທະນາຄານ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.white,
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                'ຍິນດີຕ້ອນຮັບ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: _captionFontSize,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerMenu(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: _smallPadding),
        children: [
          _buildDrawerItem(
            icon: Icons.home,
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
            icon: Icons.article,
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
            icon: Icons.photo_library,
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
            icon: Icons.info,
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
              icon: Icons.person,
              title: 'ໂປຣໄຟລ໌',
              isSelected: currentRoute == '/profile',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/profile') {
                  Navigator.pushReplacementNamed(context, '/profile');
                }
              },
            ),
          Divider(height: _basePadding * 2),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'ຕັ້ງຄ່າ',
            isSelected: false,
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.help,
            title: 'ຊ່ວຍເຫຼືອ',
            isSelected: false,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Color(0xFF07325D) : Colors.grey[600],
        size: _isExtraSmallScreen ? 22 : 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.notoSansLao(
          color: isSelected ? Color(0xFF07325D) : Colors.grey[800],
          fontSize: _bodyFontSize,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Color(0xFF07325D).withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: _basePadding,
        vertical: 4,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_basePadding),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoggedIn
                ? onLogoutPressed
                : () {
                    Navigator.pop(context);
                    onLoginPressed?.call();
                  },
            icon: Icon(
              isLoggedIn ? Icons.logout : Icons.login,
              size: _isExtraSmallScreen ? 18 : 20,
            ),
            label: Text(
              isLoggedIn ? 'ອອກຈາກລະບົບ' : 'ເຂົ້າສູ່ລະບົບ',
              style: GoogleFonts.notoSansLao(
                fontSize: _bodyFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF07325D),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
