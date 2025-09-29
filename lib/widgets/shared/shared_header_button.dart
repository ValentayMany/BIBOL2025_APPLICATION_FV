// widgets/shared/shared_header_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SharedHeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool hasNotification;
  final String? tooltip;
  final double screenWidth;

  const SharedHeaderButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.hasNotification = false,
    this.tooltip,
    required this.screenWidth,
  }) : super(key: key);

  // ใช้ค่าเดียวกันทุกหน้า - สำคัญมาก!
  double get _buttonSize {
    if (screenWidth < 320) return 40.0;
    if (screenWidth < 375) return 44.0;
    return 48.0;
  }

  double get _iconSize {
    if (screenWidth < 320) return 18.0;
    if (screenWidth < 375) return 20.0;
    return 22.0;
  }

  double get _borderRadius {
    if (screenWidth < 320) return 12.0;
    if (screenWidth < 375) return 14.0;
    return 16.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _buttonSize,
      height: _buttonSize,
      margin: const EdgeInsets.all(4.0), // ระยะห่างคงที่
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(_borderRadius),
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Center(
                child: Icon(icon, color: Colors.white, size: _iconSize),
              ),
            ),
          ),
          if (hasNotification)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget สำหรับปุ่ม Login
class SharedLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double screenWidth;

  const SharedLoginButton({
    Key? key,
    required this.onPressed,
    required this.screenWidth,
  }) : super(key: key);

  double get _buttonHeight {
    if (screenWidth < 320) return 40.0;
    if (screenWidth < 375) return 44.0;
    return 48.0;
  }

  double get _buttonWidth {
    if (screenWidth < 320) return 95.0;
    if (screenWidth < 375) return 105.0;
    return 120.0;
  }

  double get _fontSize {
    if (screenWidth < 320) return 11.0;
    if (screenWidth < 375) return 12.0;
    return 13.0;
  }

  double get _borderRadius {
    if (screenWidth < 320) return 12.0;
    if (screenWidth < 375) return 14.0;
    return 16.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _buttonWidth,
      height: _buttonHeight,
      margin: const EdgeInsets.all(4.0), // ระยะห่างเดียวกับปุ่มอื่น
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(_borderRadius),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Center(
            child: Text(
              'ເຂົ້າສູ່ລະບົບ',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: _fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
