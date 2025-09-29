// widgets/home_widgets/header_widget.dart - แก้ไขให้ใช้ SharedHeaderButton
import 'dart:ui';
import 'package:BIBOL/widgets/shared/shared_header_button.dart';
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

  double get _basePadding {
    if (screenWidth < 320) return 8.0;
    if (screenWidth < 360) return 12.0;
    if (screenWidth < 400) return 16.0;
    if (screenWidth < 480) return 18.0;
    return 20.0;
  }

  double get _logoSize {
    if (screenWidth < 320) return 50.0;
    if (screenWidth < 360) return 60.0;
    if (screenWidth < 400) return 70.0;
    if (screenWidth < 480) return 80.0;
    return 90.0;
  }

  double get _titleFontSize {
    if (screenWidth < 320) return 18.0;
    if (screenWidth < 360) return 20.0;
    if (screenWidth < 400) return 22.0;
    if (screenWidth < 480) return 24.0;
    return 26.0;
  }

  double get _subtitleFontSize {
    if (screenWidth < 320) return 10.0;
    if (screenWidth < 360) return 11.0;
    if (screenWidth < 400) return 12.0;
    if (screenWidth < 480) return 13.0;
    return 14.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_basePadding * 2),
          bottomRight: Radius.circular(_basePadding * 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF07325D).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(_basePadding),
          child: Column(
            children: [
              // Header Row - ใช้ SharedHeaderButton
              Row(
                children: [
                  SharedHeaderButton(
                    icon: Icons.menu_rounded,
                    onPressed: onMenuPressed,
                    screenWidth: screenWidth,
                  ),
                  Spacer(),
                  if (isLoggedIn && onLogoutPressed != null)
                    SharedHeaderButton(
                      icon: Icons.logout,
                      onPressed: onLogoutPressed!,
                      screenWidth: screenWidth,
                    )
                  else if (!isLoggedIn && onLoginPressed != null)
                    SharedLoginButton(
                      onPressed: onLoginPressed,
                      screenWidth: screenWidth,
                    ),
                ],
              ),

              SizedBox(height: _basePadding),

              // Logo and Title Section
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: Column(
                        children: [
                          Container(
                            width: _logoSize,
                            height: _logoSize,
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
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(_basePadding * 0.75),
                              child: Image.asset(
                                'assets/images/LOGO.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'ສະຖາບັນການທະນາຄານ',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _titleFontSize,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            isLoggedIn && userInfo != null
                                ? 'ຍິນດີຕ້ອນຮັບ ${userInfo!['fullname'] ?? ''}'
                                : '🎓 ຍິນດີຕ້ອນຮັບ 🎓',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _subtitleFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
