// widgets/home_widgets/news_card_widget.dart - Premium Design
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:BIBOL/models/topic/topic_model.dart';

class NewsCardWidget extends StatelessWidget {
  final Topic news;
  final double screenWidth;
  final VoidCallback? onTap;
  final bool isFeatured;

  const NewsCardWidget({
    Key? key,
    required this.news,
    required this.screenWidth,
    this.onTap,
    this.isFeatured = false,
  }) : super(key: key);

  // Responsive helper methods
  bool get _isExtraSmallScreen => screenWidth < 320;
  bool get _isSmallScreen => screenWidth < 375;
  bool get _isMediumScreen => screenWidth < 414;
  bool get _isTablet => screenWidth >= 600;

  double get _basePadding {
    if (_isExtraSmallScreen) return 10.0;
    if (_isSmallScreen) return 12.0;
    if (_isMediumScreen) return 16.0;
    if (_isTablet) return 24.0;
    return 20.0;
  }

  double get _smallPadding => _basePadding * 0.75;

  double get _bodyFontSize {
    if (_isExtraSmallScreen) return 13.0;
    if (_isSmallScreen) return 14.0;
    if (_isMediumScreen) return 15.0;
    if (_isTablet) return 17.0;
    return 16.0;
  }

  double get _captionFontSize {
    if (_isExtraSmallScreen) return 10.0;
    if (_isSmallScreen) return 11.0;
    if (_isMediumScreen) return 12.0;
    if (_isTablet) return 14.0;
    return 13.0;
  }

  String _stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return '';

    // ลบ HTML tags ก่อน
    String stripped = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');

    // ใช้ html_unescape เพื่อ decode HTML entities
    final unescape = HtmlUnescape();
    stripped = unescape.convert(stripped);

    // ทำความสะอาด whitespace
    stripped = stripped.replaceAll(RegExp(r'\s+'), ' ').trim();

    return stripped;
  }

  @override
  Widget build(BuildContext context) {
    return isFeatured ? _buildFeaturedNewsCard() : _buildCompactNewsCard();
  }

  Widget _buildFeaturedNewsCard() {
    final cardHeight = _isExtraSmallScreen
        ? 160.0
        : _isSmallScreen
        ? 180.0
        : _isMediumScreen
        ? 200.0
        : _isTablet
        ? 280.0
        : 250.0;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color(0xFF10B981).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF10B981).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: _isExtraSmallScreen || _isSmallScreen
              ? _buildVerticalLayout(cardHeight)
              : _buildHorizontalLayout(cardHeight),
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(double cardHeight) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: cardHeight * 0.5,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: _buildNewsImage(news.photoFile),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF10B981).withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fiber_new_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ໃໝ່',
                      style: GoogleFonts.notoSansLao(
                        fontSize: _captionFontSize * 0.9,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(_basePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _stripHtmlTags(news.title),
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF07325D),
                      height: 1.3,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: _captionFontSize,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${news.visits}',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _captionFontSize * 0.9,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF07325D).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: _captionFontSize,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ອ່ານ',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _captionFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(double cardHeight) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: _isMediumScreen
                  ? 140.0
                  : _isTablet
                  ? 180.0
                  : 160.0,
              height: cardHeight,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                child: _buildNewsImage(news.photoFile),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF10B981).withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fiber_new_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ໃໝ່',
                      style: GoogleFonts.notoSansLao(
                        fontSize: _captionFontSize * 0.9,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(_basePadding * 1.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: _captionFontSize,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${news.visits}',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _captionFontSize * 0.9,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _stripHtmlTags(news.title),
                  style: GoogleFonts.notoSansLao(
                    fontSize: _bodyFontSize * 1.2,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF07325D),
                    height: 1.3,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    _stripHtmlTags(news.details),
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize * 0.9,
                      color: Colors.grey[600],
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: _isMediumScreen ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _basePadding,
                        vertical: _smallPadding * 0.6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF07325D).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: _captionFontSize * 1.1,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'ອ່ານເພີ່ມ',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _captionFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactNewsCard() {
    final cardHeight = _isExtraSmallScreen
        ? 180.0
        : _isSmallScreen
        ? 200.0
        : 220.0;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF07325D).withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF07325D).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: cardHeight * 0.45,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: _buildNewsImage(
                        news.photoFile,
                        height: cardHeight * 0.45,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(
                    _isExtraSmallScreen ? 10.0 : _basePadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _stripHtmlTags(news.title),
                          style: GoogleFonts.notoSansLao(
                            fontSize: _bodyFontSize,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF07325D),
                            height: 1.3,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_rounded,
                                  size: _captionFontSize,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${news.visits}',
                                  style: GoogleFonts.notoSansLao(
                                    fontSize: _captionFontSize * 0.9,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: _captionFontSize * 1.1,
                              color: Colors.white,
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
        ),
      ),
    );
  }

  Widget _buildNewsImage(String imageUrl, {double? height}) {
    if (imageUrl.isNotEmpty && Uri.tryParse(imageUrl) != null) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.article_rounded,
                size: height != null ? height * 0.3 : 60.0,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[200]!, Colors.grey[100]!],
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.article_rounded,
          size: height != null ? height * 0.3 : 60.0,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}
