// widgets/home_widgets/news_card_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    if (_isExtraSmallScreen) return 12.0;
    if (_isSmallScreen) return 13.0;
    if (_isMediumScreen) return 14.0;
    if (_isTablet) return 16.0;
    return 15.0;
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

    String stripped = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');

    stripped = stripped
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/')
        .replaceAll('&hellip;', '...')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–');

    stripped = stripped.replaceAll(RegExp(r'\s+'), ' ').trim();

    return stripped;
  }

  @override
  Widget build(BuildContext context) {
    return isFeatured ? _buildFeaturedNewsCard() : _buildCompactNewsCard();
  }

  Widget _buildFeaturedNewsCard() {
    final cardHeight =
        _isExtraSmallScreen
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child:
              _isExtraSmallScreen || _isSmallScreen
                  ? _buildVerticalLayout(cardHeight)
                  : _buildHorizontalLayout(cardHeight),
        ),
      ),
    );
  }

  Widget _buildVerticalLayout(double cardHeight) {
    return Column(
      children: [
        Container(
          height: cardHeight * 0.5,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: _buildNewsImage(news.photoFile),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(_smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stripHtmlTags(news.title),
                  style: GoogleFonts.notoSansLao(
                    fontSize: _bodyFontSize * 0.9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: _captionFontSize,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${news.visits}',
                          style: GoogleFonts.notoSansLao(
                            fontSize: _captionFontSize * 0.8,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07325D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ອ່ານ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: _captionFontSize * 0.8,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
        Container(
          width:
              _isMediumScreen
                  ? 120.0
                  : _isTablet
                  ? 160.0
                  : 140.0,
          height: cardHeight,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: _buildNewsImage(news.photoFile),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(_basePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF07325D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ຂ່າວໃໝ່',
                          style: GoogleFonts.notoSansLao(
                            fontSize: _captionFontSize,
                            color: const Color(0xFF07325D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: _captionFontSize,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${news.visits}',
                          style: GoogleFonts.notoSansLao(
                            fontSize: _captionFontSize * 0.8,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _stripHtmlTags(news.title),
                  style: GoogleFonts.notoSansLao(
                    fontSize: _bodyFontSize * 1.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    _stripHtmlTags(news.details),
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: _isMediumScreen ? 2 : 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _smallPadding,
                        vertical: _smallPadding * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07325D),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'ອ່ານເພີ່ມ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: _captionFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
    final cardHeight =
        _isExtraSmallScreen
            ? 180.0
            : _isSmallScreen
            ? 200.0
            : 220.0;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: cardHeight * 0.4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: _buildNewsImage(
                    news.photoFile,
                    height: cardHeight * 0.4,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(
                    _isExtraSmallScreen ? 8.0 : _smallPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stripHtmlTags(news.title),
                        style: GoogleFonts.notoSansLao(
                          fontSize: _bodyFontSize * 0.9,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          _stripHtmlTags(news.details),
                          style: GoogleFonts.notoSansLao(
                            fontSize: _captionFontSize,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: _captionFontSize,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${news.visits}',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _captionFontSize * 0.8,
                              color: Colors.grey[400],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: _captionFontSize,
                            color: const Color(0xFF07325D),
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
                colors: [
                  const Color(0xFF07325D).withOpacity(0.7),
                  const Color(0xFF0A4A73).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.article,
              size: height != null ? height * 0.3 : 60.0,
              color: Colors.white,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: const Center(
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
          colors: [
            const Color(0xFF07325D).withOpacity(0.7),
            const Color(0xFF0A4A73).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.article,
        size: height != null ? height * 0.3 : 60.0,
        color: Colors.white,
      ),
    );
  }
}
