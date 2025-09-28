// widgets/news_widgets/news_empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsEmptyStateWidget extends StatelessWidget {
  final bool isFiltered;
  final String selectedCategoryName;
  final String searchQuery;
  final VoidCallback? onClearFilter;
  final VoidCallback? onRefresh;

  const NewsEmptyStateWidget({
    Key? key,
    required this.isFiltered,
    required this.selectedCategoryName,
    required this.searchQuery,
    this.onClearFilter,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = _getBasePadding(screenWidth);
    final titleFontSize = _getTitleFontSize(screenWidth);
    final bodyFontSize = _getBodyFontSize(screenWidth);
    final logoSize = _getLogoSize(screenWidth);
    final iconSize = _getIconSize(screenWidth);

    return Container(
      padding: EdgeInsets.all(basePadding * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: logoSize * 1.5,
            height: logoSize * 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF07325D).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              isFiltered ? Icons.filter_alt_outlined : Icons.article_outlined,
              size: logoSize * 0.8,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 32),
          Text(
            _getTitle(),
            style: GoogleFonts.notoSansLao(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            _getSubtitle(),
            style: GoogleFonts.notoSansLao(
              color: Colors.grey[500],
              fontSize: bodyFontSize,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          if (_shouldShowButton()) ...[
            SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF07325D).withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _getButtonAction(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: basePadding * 1.5,
                    vertical: basePadding * 0.75,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getButtonIcon(), color: Colors.white, size: iconSize),
                    SizedBox(width: 8),
                    FittedBox(
                      child: Text(
                        _getButtonText(),
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: bodyFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getTitle() {
    if (isFiltered) {
      return 'ບໍ່ມີຂ່າວໃນໝວດ "$selectedCategoryName"';
    } else if (searchQuery.isNotEmpty) {
      return 'ບໍ່ພົບຂ່າວ';
    } else {
      return 'ຍັງບໍ່ມີຂ່າວ';
    }
  }

  String _getSubtitle() {
    if (isFiltered) {
      return 'ລອງເລືອກໝວດອື່ນເບິ່ງ';
    } else if (searchQuery.isNotEmpty) {
      return 'ລອງຄົ້ນຫາຄຳອື່ນ';
    } else {
      return 'ຂ່າວຈະອັບເດດໃນໄວໆນີ້';
    }
  }

  bool _shouldShowButton() {
    return isFiltered || searchQuery.isNotEmpty;
  }

  IconData _getButtonIcon() {
    return isFiltered ? Icons.grid_view_rounded : Icons.refresh_rounded;
  }

  String _getButtonText() {
    return isFiltered ? 'ເບິ່ງຂ່າວທັງໝົດ' : 'ລ້າງການຄົ້ນຫາ';
  }

  VoidCallback? _getButtonAction() {
    return isFiltered ? onClearFilter : onRefresh;
  }

  double _getBasePadding(double screenWidth) {
    if (screenWidth < 320) return 8.0;
    if (screenWidth < 360) return 12.0;
    if (screenWidth < 400) return 16.0;
    if (screenWidth < 480) return 18.0;
    if (screenWidth < 600) return 20.0;
    return 24.0;
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 320) return 18.0;
    if (screenWidth < 360) return 20.0;
    if (screenWidth < 400) return 22.0;
    if (screenWidth < 480) return 24.0;
    return 26.0;
  }

  double _getBodyFontSize(double screenWidth) {
    if (screenWidth < 320) return 11.0;
    if (screenWidth < 360) return 12.0;
    if (screenWidth < 400) return 13.0;
    if (screenWidth < 480) return 14.0;
    return 15.0;
  }

  double _getLogoSize(double screenWidth) {
    if (screenWidth < 320) return 50.0;
    if (screenWidth < 360) return 60.0;
    if (screenWidth < 400) return 70.0;
    if (screenWidth < 480) return 80.0;
    return 90.0;
  }

  double _getIconSize(double screenWidth) {
    if (screenWidth < 320) return 16.0;
    if (screenWidth < 360) return 18.0;
    if (screenWidth < 400) return 20.0;
    if (screenWidth < 480) return 22.0;
    return 24.0;
  }
}
