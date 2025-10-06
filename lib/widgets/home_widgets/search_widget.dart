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

class _SearchWidgetState extends State<SearchWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color:
                  _isFocused
                      ? Color(0xFF07325D).withOpacity(0.25)
                      : Colors.black.withOpacity(0.1),
              blurRadius: _isFocused ? 20 : 15,
              offset: Offset(0, _isFocused ? 6 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    _isFocused ? Color(0xFFF8FAFF) : Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color:
                      _isFocused
                          ? Color(0xFF07325D).withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                  width: _isFocused ? 2 : 1.5,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: (value) {
                  setState(() {});
                  widget.onChanged?.call(value);
                },
                style: GoogleFonts.notoSansLao(
                  fontSize: _bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF07325D),
                ),
                decoration: InputDecoration(
                  hintText:
                      _isExtraSmallScreen
                          ? 'ຄົ້ນຫາ...'
                          : _isSmallScreen
                          ? 'ຄົ້ນຫາຫຼັກສູດ...'
                          : 'ຄົ້ນຫາຫຼັກສູດ ຫຼື ຂ່າວສານ...',
                  hintStyle: GoogleFonts.notoSansLao(
                    color: Colors.grey[400],
                    fontSize: _bodyFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    padding: EdgeInsets.all(_smallPadding),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(_smallPadding * 0.3),
                      decoration: BoxDecoration(
                        gradient:
                            _isFocused
                                ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF07325D),
                                    Color(0xFF0A4A85),
                                  ],
                                )
                                : null,
                        color: _isFocused ? null : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: _isFocused ? Colors.white : Color(0xFF07325D),
                        size:
                            _isExtraSmallScreen
                                ? 16.0
                                : _isSmallScreen
                                ? 18.0
                                : 20.0,
                      ),
                    ),
                  ),
                  suffixIcon:
                      widget.controller.text.isNotEmpty
                          ? Container(
                            padding: EdgeInsets.all(_smallPadding),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  widget.controller.clear();
                                  setState(() {});
                                  widget.onChanged?.call('');
                                },
                                child: Container(
                                  padding: EdgeInsets.all(_smallPadding * 0.5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.grey[600],
                                    size:
                                        _isExtraSmallScreen
                                            ? 14.0
                                            : _isSmallScreen
                                            ? 16.0
                                            : 18.0,
                                  ),
                                ),
                              ),
                            ),
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: _smallPadding,
                    vertical: _isExtraSmallScreen ? 12.0 : _basePadding,
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
