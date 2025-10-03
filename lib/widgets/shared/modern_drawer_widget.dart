// widgets/home_widgets/modern_drawer_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernDrawerWidget extends StatefulWidget {
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

  @override
  State<ModernDrawerWidget> createState() => _ModernDrawerWidgetState();
}

class _ModernDrawerWidgetState extends State<ModernDrawerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Responsive helper methods
  bool get _isExtraSmallScreen => widget.screenWidth < 320;
  bool get _isSmallScreen => widget.screenWidth < 375;
  bool get _isShortScreen => widget.screenHeight < 667;
  bool get _isTablet => widget.screenWidth >= 600;

  double get _basePadding {
    if (_isExtraSmallScreen) return 10.0;
    if (_isSmallScreen) return 12.0;
    if (_isTablet) return 24.0;
    return 20.0;
  }

  double get _smallPadding => _basePadding * 0.75;

  double get _titleFontSize {
    if (_isExtraSmallScreen) return 18.0;
    if (_isSmallScreen) return 20.0;
    if (_isTablet) return 30.0;
    return 26.0;
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
    final drawerWidth = widget.screenWidth *
        (_isExtraSmallScreen
            ? 0.9
            : _isSmallScreen
                ? 0.85
                : 0.8);

    return Drawer(
      backgroundColor: Colors.transparent,
      width: drawerWidth,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF07325D).withOpacity(0.95),
                      const Color(0xFF0A4A85).withOpacity(0.95),
                      const Color(0xFF0D5A9C).withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background Pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.05,
                        child: CustomPaint(
                          painter: _DrawerPatternPainter(),
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: Column(
                        children: [
                          _buildDrawerHeader(context),
                          Expanded(child: _buildDrawerMenu(context)),
                          _buildDrawerFooter(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final avatarSize = _isExtraSmallScreen
        ? 60.0
        : _isShortScreen
            ? 70.0
            : _isTablet
                ? 100.0
                : 85.0;
    final maxTextWidth = widget.screenWidth *
        (_isExtraSmallScreen
            ? 0.7
            : _isSmallScreen
                ? 0.65
                : 0.6);

    return Container(
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
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Avatar with glow effect
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.9),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isLoggedIn
                        ? Icons.account_circle_rounded
                        : Icons.menu_book_rounded,
                    color: const Color(0xFF07325D),
                    size: avatarSize * 0.55,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: _basePadding),
          
          // Greeting
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.9),
              ],
            ).createShader(bounds),
            child: Text(
              'ສະບາຍດີ! 👋',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: _titleFontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          if (widget.isLoggedIn && widget.userInfo != null) ...[
            const SizedBox(height: 12),
            Container(
              constraints: BoxConstraints(maxWidth: maxTextWidth),
              padding: EdgeInsets.symmetric(
                horizontal: _basePadding,
                vertical: _smallPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "${widget.userInfo!['first_name'] ?? ''} ${widget.userInfo!['last_name'] ?? ''}"
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
                  if (widget.userInfo!['student_id'] != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.badge,
                            color: Colors.white.withOpacity(0.9),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.userInfo!['student_id']}',
                            style: GoogleFonts.notoSansLao(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: _captionFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else
            Container(
              constraints: BoxConstraints(maxWidth: maxTextWidth),
              child: Text(
                'ຍິນດີຕ້ອນຮັບເຂົ້າສູ່ລະບົບ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.white.withOpacity(0.9),
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
      margin: EdgeInsets.symmetric(
        horizontal: _basePadding,
        vertical: _smallPadding,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildDrawerItem(
              icon: Icons.home_rounded,
              title: 'ໜ້າຫຼັກ',
              isSelected: widget.currentRoute == '/home' ||
                  widget.currentRoute == null,
              onTap: () {
                Navigator.pop(context);
                if (widget.currentRoute != '/home' &&
                    widget.currentRoute != null) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
            _buildDrawerItem(
              icon: Icons.newspaper_rounded,
              title: 'ຂ່າວສານ',
              isSelected: widget.currentRoute == '/news',
              onTap: () {
                Navigator.pop(context);
                if (widget.currentRoute != '/news') {
                  Navigator.pushReplacementNamed(context, '/news');
                }
              },
            ),
            _buildDrawerItem(
              icon: Icons.photo_library_rounded,
              title: 'ຮູບພາບ',
              isSelected: widget.currentRoute == '/gallery',
              onTap: () {
                Navigator.pop(context);
                if (widget.currentRoute != '/gallery') {
                  Navigator.pushReplacementNamed(context, '/gallery');
                }
              },
            ),
            _buildDrawerItem(
              icon: Icons.info_rounded,
              title: 'ກ່ຽວກັບ',
              isSelected: widget.currentRoute == '/about',
              onTap: () {
                Navigator.pop(context);
                if (widget.currentRoute != '/about') {
                  Navigator.pushReplacementNamed(context, '/about');
                }
              },
            ),
            if (widget.isLoggedIn)
              _buildDrawerItem(
                icon: Icons.person_rounded,
                title: 'ໂປຣໄຟລ໌',
                isSelected: widget.currentRoute == '/profile',
                onTap: () {
                  Navigator.pop(context);
                  if (widget.currentRoute != '/profile') {
                    Navigator.pushReplacementNamed(context, '/profile');
                  }
                },
              ),
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
    final itemHeight = _isExtraSmallScreen
        ? 48.0
        : _isSmallScreen
            ? 52.0
            : 56.0;
    final iconSize = _isExtraSmallScreen
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
                        Colors.white.withOpacity(0.15),
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
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
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
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
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
    final buttonHeight = _isExtraSmallScreen
        ? 44.0
        : _isSmallScreen
            ? 48.0
            : 52.0;

    return Container(
      padding: EdgeInsets.all(_basePadding * 1.2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 300, minHeight: buttonHeight),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoggedIn
                ? widget.onLogoutPressed
                : () {
                    Navigator.pop(context);
                    widget.onLoginPressed?.call();
                  },
            borderRadius: BorderRadius.circular(30),
            splashColor: Colors.white.withOpacity(0.1),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _basePadding,
                vertical: _smallPadding * 1.2,
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
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
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
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isLoggedIn
                          ? Icons.logout_rounded
                          : Icons.login_rounded,
                      color: Colors.white,
                      size: _isExtraSmallScreen
                          ? 16.0
                          : _isSmallScreen
                              ? 18.0
                              : 20.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.isLoggedIn ? 'ອອກຈາກລະບົບ' : 'ເຂົ້າສູ່ລະບົບ',
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: _bodyFontSize,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
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

// Custom painter for background pattern
class _DrawerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const spacing = 40.0;
    
    // Draw diagonal lines
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
