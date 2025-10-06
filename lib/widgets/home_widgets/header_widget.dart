// widgets/home_widgets/header_widget.dart - Premium Design
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
    if (screenWidth < 320) return 55.0;
    if (screenWidth < 360) return 65.0;
    if (screenWidth < 400) return 75.0;
    if (screenWidth < 480) return 85.0;
    return 95.0;
  }

  double get _titleFontSize {
    if (screenWidth < 320) return 20.0;
    if (screenWidth < 360) return 22.0;
    if (screenWidth < 400) return 24.0;
    if (screenWidth < 480) return 26.0;
    return 28.0;
  }

  double get _subtitleFontSize {
    if (screenWidth < 320) return 11.0;
    if (screenWidth < 360) return 12.0;
    if (screenWidth < 400) return 13.0;
    if (screenWidth < 480) return 14.0;
    return 15.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06304F), Color(0xFF07325D), Color(0xFF0A4A85)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_basePadding * 2.5),
          bottomRight: Radius.circular(_basePadding * 2.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF07325D).withOpacity(0.4),
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(_basePadding * 1.2),
          child: Column(
            children: [
              // Header Row
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
                      icon: Icons.logout_rounded,
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

              SizedBox(height: _basePadding * 1.5),

              // Logo and Title Section with Animation
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
                          // Logo with Glow Effect
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow
                              Container(
                                width: _logoSize + 20,
                                height: _logoSize + 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              // Logo container
                              Container(
                                width: _logoSize,
                                height: _logoSize,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.25),
                                      Colors.white.withOpacity(0.15),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 25,
                                      offset: Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(_basePadding * 0.8),
                                  child: Image.asset(
                                    'assets/images/LOGO.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Title with Shadow
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: _basePadding,
                              vertical: _basePadding * 0.3,
                            ),
                            child: Text(
                              'ສະຖາບັນການທະນາຄານ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: _titleFontSize,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 6),

                          // Subtitle with Badge Style
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: _basePadding * 1.2,
                              vertical: _basePadding * 0.5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isLoggedIn && userInfo != null) ...[
                                  Icon(
                                    Icons.account_circle_rounded,
                                    color: Colors.white,
                                    size: _subtitleFontSize * 1.2,
                                  ),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'ຍິນດີຕ້ອນຮັບ ${userInfo!['fullname'] ?? ''}',
                                      style: GoogleFonts.notoSansLao(
                                        fontSize: _subtitleFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    '🎓',
                                    style: TextStyle(
                                      fontSize: _subtitleFontSize * 1.2,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'ຍິນດີຕ້ອນຮັບ',
                                    style: GoogleFonts.notoSansLao(
                                      fontSize: _subtitleFontSize,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '🎓',
                                    style: TextStyle(
                                      fontSize: _subtitleFontSize * 1.2,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: _basePadding * 0.5),
            ],
          ),
        ),
      ),
    );
  }
}
