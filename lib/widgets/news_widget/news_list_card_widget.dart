// widgets/news_widgets/news_list_card_widget.dart
// ignore_for_file: unused_local_variable, sized_box_for_whitespace, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:BIBOL/models/topic/topic_model.dart';

class NewsListCardWidget extends StatelessWidget {
  final Topic topic;
  final VoidCallback onTap;
  final int index;

  const NewsListCardWidget({
    Key? key,
    required this.topic,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Enhanced responsive breakpoints
    final isVerySmallScreen = screenWidth < 320;
    final isTinyScreen = screenWidth < 360;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth < 480;

    // Responsive dimensions
    final basePadding = _getBasePadding(screenWidth);
    final smallPadding = basePadding * 0.75;
    final subtitleFontSize = _getSubtitleFontSize(screenWidth);
    final captionFontSize = _getCaptionFontSize(screenWidth);
    final iconSize = _getIconSize(screenWidth);

    final gradients = [
      LinearGradient(colors: [Color(0xFF07325D), Color(0xFF0A4A85)]),
      LinearGradient(colors: [Color(0xFF07325D), Color(0xFF1D5A96)]),
      LinearGradient(colors: [Color(0xFF0A4A85), Color(0xFF07325D)]),
      LinearGradient(colors: [Color(0xFF1D5A96), Color(0xFF07325D)]),
      LinearGradient(
        colors: [Color(0xFF07325D).withOpacity(0.8), Color(0xFF0A4A85)],
      ),
      LinearGradient(colors: [Color(0xFF0A4A85), Color(0xFF1D5A96)]),
    ];

    final cardGradient = gradients[index % gradients.length];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(basePadding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(basePadding),
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section
                    Expanded(
                      flex: isVerySmallScreen ? 5 : 4,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            child:
                                topic.hasImage && topic.photoFile.isNotEmpty
                                    ? Image.network(
                                      topic.photoFile,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: cardGradient,
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: cardGradient,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.article_rounded,
                                              color: Colors.white,
                                              size: iconSize * 1.5,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    : Container(
                                      decoration: BoxDecoration(
                                        gradient: cardGradient,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.article_rounded,
                                          color: Colors.white,
                                          size: iconSize * 1.5,
                                        ),
                                      ),
                                    ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.2),
                                ],
                                stops: [0.0, 0.3, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content section
                    Expanded(
                      flex: isVerySmallScreen ? 3 : 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: smallPadding,
                          vertical: smallPadding * 0.9,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: Text(
                                  topic.displayTitle,
                                  style: GoogleFonts.notoSansLao(
                                    fontSize: subtitleFontSize,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey[900],
                                    height: 1.25,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: isVerySmallScreen ? 2 : 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(height: smallPadding * 0.6),
                            // Bottom section
                            Container(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.visibility_rounded,
                                        size: iconSize * 0.7,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${topic.visits}',
                                        style: GoogleFonts.notoSansLao(
                                          fontSize: captionFontSize,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Container(
                                    height: isVerySmallScreen ? 26 : 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF07325D),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF07325D,
                                          ).withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: onTap,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: basePadding,
                                            vertical: smallPadding * 0.6,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'ອ່ານ',
                                            style: GoogleFonts.notoSansLao(
                                              color: Colors.white,
                                              fontSize: captionFontSize,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

  double _getIconSize(double screenWidth) {
    if (screenWidth < 320) return 16.0;
    if (screenWidth < 360) return 18.0;
    if (screenWidth < 400) return 20.0;
    if (screenWidth < 480) return 22.0;
    return 24.0;
  }
}
