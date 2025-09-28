// widgets/news_widgets/news_category_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:BIBOL/models/topic/joined_category_model.dart';

class NewsCategoryFilterWidget extends StatelessWidget {
  final List<JoinedCategory> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  const NewsCategoryFilterWidget({
    Key? key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = _getBasePadding(screenWidth);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: basePadding, vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildCategoryChip(
              id: 'all',
              title: 'ທັງໝົດ',
              icon: Icons.grid_view_rounded,
              isSelected: selectedCategoryId == 'all',
              screenWidth: screenWidth,
            ),
            SizedBox(width: 16),
            ...categories.map((category) {
              return Padding(
                padding: EdgeInsets.only(right: 16),
                child: _buildCategoryChip(
                  id: category.id.toString(),
                  title: category.title,
                  icon: Icons.label_rounded,
                  isSelected: selectedCategoryId == category.id.toString(),
                  screenWidth: screenWidth,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String id,
    required String title,
    required IconData icon,
    required bool isSelected,
    required double screenWidth,
  }) {
    final basePadding = _getBasePadding(screenWidth);
    final smallPadding = basePadding * 0.75;
    final subtitleFontSize = _getSubtitleFontSize(screenWidth);
    final iconSize = _getIconSize(screenWidth);

    return GestureDetector(
      onTap: () => onCategorySelected(id),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        padding: EdgeInsets.symmetric(
          horizontal: basePadding,
          vertical: smallPadding,
        ),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                  )
                  : null,
          color: isSelected ? null : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
                isSelected
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Color(0xFF07325D).withOpacity(0.4),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize * 0.8,
              color: isSelected ? Colors.white : Color(0xFF07325D),
            ),
            SizedBox(width: smallPadding * 0.5),
            Text(
              title,
              style: GoogleFonts.notoSansLao(
                fontSize: subtitleFontSize,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getBasePadding(double screenWidth) {
    if (screenWidth < 320) return 8.0;
    if (screenWidth < 360) return 12.0;
    if (screenWidth < 400) return 16.0;
    if (screenWidth < 480) return 18.0;
    if (screenWidth < 600) return 20.0;
    return 24.0;
  }

  double _getSubtitleFontSize(double screenWidth) {
    if (screenWidth < 320) return 10.0;
    if (screenWidth < 360) return 11.0;
    if (screenWidth < 400) return 12.0;
    if (screenWidth < 480) return 13.0;
    return 14.0;
  }

  double _getIconSize(double screenWidth) {
    if (screenWidth < 320) return 16.0;
    if (screenWidth < 360) return 18.0;
    if (screenWidth < 400) return 20.0;
    if (screenWidth < 480) return 22.0;
    return 24.0;
  }
}
