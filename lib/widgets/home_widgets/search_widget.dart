// widgets/home_widgets/search_widget.dart - Premium Design
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
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
        height: _isExtraSmallScreen ? 50 : 56,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.grey[600], size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Hint text เมื่อ searchQuery ยังว่าง
                  if (widget.controller.text.isEmpty)
                    Text(
                      _isExtraSmallScreen
                          ? 'ຄົ້ນຫາ...'
                          : _isSmallScreen
                          ? 'ຄົ້ນຫາຫຼັກສູດ...'
                          : 'ຄົ້ນຫາຫຼັກສູດ ຫຼື ຂ່າວສານ...',
                      style: GoogleFonts.notoSansLao(
                        fontSize: _bodyFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    onChanged: (value) {
                      setState(() {});
                      widget.onChanged?.call(value);
                    },
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    decoration: null, // ไม่มี InputDecoration
                    cursorColor: Color(0xFF07325D),
                  ),
                ],
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  setState(() {});
                  widget.onChanged?.call('');
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.grey[700],
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
