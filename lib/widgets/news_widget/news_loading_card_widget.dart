// widgets/news_widgets/news_loading_card_widget.dart
import 'package:flutter/material.dart';

class NewsLoadingCardWidget extends StatelessWidget {
  const NewsLoadingCardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = _getBasePadding(screenWidth);
    final smallPadding = basePadding * 0.75;
    final subtitleFontSize = _getSubtitleFontSize(screenWidth);
    final captionFontSize = _getCaptionFontSize(screenWidth);
    final isVerySmallScreen = screenWidth < 320;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(basePadding),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: isVerySmallScreen ? 5 : 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(basePadding),
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(smallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: subtitleFontSize,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: subtitleFontSize,
                    width: double.infinity * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Container(
                        height: captionFontSize,
                        width: isVerySmallScreen ? 30 : 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: isVerySmallScreen ? 22 : 26,
                        width: isVerySmallScreen ? 40 : 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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

  double _getCaptionFontSize(double screenWidth) {
    if (screenWidth < 320) return 9.0;
    if (screenWidth < 360) return 10.0;
    if (screenWidth < 400) return 11.0;
    return 12.0;
  }
}
