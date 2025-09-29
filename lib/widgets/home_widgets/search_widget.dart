// widgets/home_widgets/search_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class SearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final double screenWidth;

  const SearchWidget({
    Key? key,
    required this.controller,
    this.onChanged,
    required this.screenWidth,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  // Responsive helper methods
  bool get _isExtraSmallScreen => widget.screenWidth < 320;
  bool get _isSmallScreen => widget.screenWidth < 375;
  bool get _isMediumScreen => widget.screenWidth < 414;
  bool get _isTablet => widget.screenWidth >= 600;

  double get _basePadding {
    if (_isExtraSmallScreen) return 10.0;
    if (_isSmallScreen) return 12.0;
    if (_isMediumScreen) return 16.0;
    if (_isTablet) return 24.0;
    return 20.0;
  }

  double get _smallPadding => _basePadding * 0.75;

  double get _bodyFontSize {
    if (_isExtraSmallScreen) return 12.0;
    if (_isSmallScreen) return 13.0;
    if (_isMediumScreen) return 14.0;
    if (_isTablet) return 16.0;
    return 15.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _basePadding,
        vertical: _basePadding,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                onChanged: (value) {
                  setState(() {});
                  widget.onChanged?.call(value);
                },
                style: GoogleFonts.notoSansLao(fontSize: _bodyFontSize),
                decoration: InputDecoration(
                  hintText:
                      _isExtraSmallScreen
                          ? 'ຄົ້ນຫາ...'
                          : _isSmallScreen
                          ? 'ຄົ້ນຫາຫຼັກສູດ...'
                          : 'ຄົ້ນຫາຫຼັກສູດ ຫຼື ຂ່າວສານ...',
                  hintStyle: GoogleFonts.notoSansLao(
                    color: Colors.grey[500],
                    fontSize: _bodyFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    padding: EdgeInsets.all(_smallPadding * 0.8),
                    child: Icon(
                      Icons.search_rounded,
                      color: const Color(0xFF07325D),
                      size:
                          _isExtraSmallScreen
                              ? 18.0
                              : _isSmallScreen
                              ? 20.0
                              : 26.0,
                    ),
                  ),
                  suffixIcon:
                      widget.controller.text.isNotEmpty
                          ? Container(
                            padding: const EdgeInsets.all(8),
                            child: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey[600],
                                  size:
                                      _isExtraSmallScreen
                                          ? 10.0
                                          : _isSmallScreen
                                          ? 12.0
                                          : 16.0,
                                ),
                              ),
                              onPressed: () {
                                widget.controller.clear();
                                setState(() {});
                                widget.onChanged?.call('');
                              },
                            ),
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: _smallPadding,
                    vertical: _isExtraSmallScreen ? 10.0 : _smallPadding,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
