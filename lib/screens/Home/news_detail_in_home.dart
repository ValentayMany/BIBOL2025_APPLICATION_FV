import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:BIBOL/services/news/news_service.dart';
import 'package:BIBOL/models/topic/topic_model.dart';
import 'package:intl/intl.dart';

class NewsDetailPage extends StatefulWidget {
  final String newsId;

  const NewsDetailPage({Key? key, required this.newsId}) : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  Topic? _news;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNewsDetail();
  }

  Future<void> _fetchNewsDetail() async {
    try {
      print('🔍 DEBUG: Starting to fetch news with ID: ${widget.newsId}');
      final news = await NewsService.getNewsById(widget.newsId);

      if (mounted) {
        setState(() {
          if (news != null) {
            print('✅ DEBUG: Successfully received news: ${news.title}');
            _news = news;
            _errorMessage = null;
          } else {
            print('❌ DEBUG: News is null');
            _errorMessage = 'ບໍ່ພົບຂ່າວທີ່ເລືອກ (ID: ${widget.newsId})';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ DEBUG: Exception in _fetchNewsDetail: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'ບໍ່ສາມາດໂຫຼດຂ່າວໄດ້: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // ✅ ปรับปรุงการแยก HTML content และรูปภาพ
  Map<String, dynamic> _parseHtmlContent(String htmlString) {
    if (htmlString.isEmpty) return {'text': '', 'images': []};

    // หา URLs ของรูปภาพใน HTML
    final RegExp imgRegExp = RegExp(
      r'<img[^>]+src="([^"]*)"[^>]*>',
      caseSensitive: false,
    );
    final Iterable<RegExpMatch> imgMatches = imgRegExp.allMatches(htmlString);

    List<String> imageUrls = [];
    for (final RegExpMatch match in imgMatches) {
      final String? imageUrl = match.group(1);
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageUrls.add(imageUrl);
      }
    }

    // ลบ HTML tags ทั้งหมด
    String cleanText = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');

    // แปลง HTML entities
    cleanText = cleanText
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

    // ทำความสะอาด whitespace
    cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();

    return {'text': cleanText, 'images': imageUrls};
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateFormat('dd/MM/yyyy').format(DateTime.now());
    }

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body:
          _isLoading
              ? _buildLoadingScreen()
              : _errorMessage != null
              ? _buildErrorScreen()
              : _buildMainContent(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
          ),
          SizedBox(height: 16),
          Text(
            'ກຳລັງໂຫຼດ...',
            style: GoogleFonts.notoSansLao(
              fontSize: 16,
              color: Color(0xFF07325D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            _errorMessage ?? 'ເກີດຂໍ້ຜິດພາດ',
            style: GoogleFonts.notoSansLao(
              fontSize: 16,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'News ID: ${widget.newsId}',
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF07325D)),
            child: Text(
              'ກັບຄືນ',
              style: GoogleFonts.notoSansLao(color: Colors.white),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _fetchNewsDetail();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
            child: Text(
              'ລອງໃໝ່',
              style: GoogleFonts.notoSansLao(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_news == null) return _buildErrorScreen();

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          backgroundColor: Color(0xFF07325D),
          pinned: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text(
            'ຂ່າວສານ',
            style: GoogleFonts.notoSansLao(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // actions: [
          //   IconButton(
          //     onPressed: () {
          //       // Share functionality
          //     },
          //     icon: Icon(Icons.share, color: Colors.white),
          //   ),
          // ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with official document style
                _buildOfficialHeader(),

                // Main News Image (photo_file)
                if (_news!.photoFile.isNotEmpty) _buildMainNewsImage(),

                // News Title
                _buildNewsTitle(),

                // News Meta Info
                _buildNewsMetaInfo(),

                // News Content with embedded images
                _buildFullNewsContent(),

                // Footer
                _buildFooter(),

                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfficialHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Column(
        children: [
          // Logo and Institution Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF07325D),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Institution Names
          Text(
            'ສາທາລະນະລັດ ປະຊາທິປະໄຕ ປະຊາຊົນລາວ',
            style: GoogleFonts.notoSansLao(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF07325D),
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'ສັນຕິພາບ ເອກະລາດ ປະຊາທິປະໄຕ ເອກະພາບ ວັດທະນາຖາວອນ',
            style: GoogleFonts.notoSansLao(
              fontSize: 12,
              color: Color(0xFF07325D),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),

          Text(
            'ສະຖາບັນການທະນາຄານ',
            style: GoogleFonts.notoSansLao(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF07325D),
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Banking Institute',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF07325D),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20),

          // Divider line
          Container(
            height: 2,
            width: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ รูปภาพหลักของข่าว (photo_file)
  Widget _buildMainNewsImage() {
    return Container(
      margin: EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _news!.photoFile,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 8),
                  Text(
                    'ບໍ່ສາມາດໂຫຼດຮູບພາບໄດ້',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewsTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ແຈ້ງການ',
            style: GoogleFonts.notoSansLao(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF07325D),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            _parseHtmlContent(_news!.title)['text'],
            style: GoogleFonts.notoSansLao(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ แสดงเนื้อหาข่าวพร้อมรูปภาพที่ฝังอยู่ในเนื้อหา
  Widget _buildFullNewsContent() {
    final contentData = _parseHtmlContent(_news!.details);
    final String cleanText = contentData['text'];
    final List<String> embeddedImages = List<String>.from(
      contentData['images'],
    );

    return Container(
      margin: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แสดงเนื้อหาข้อความ
          if (cleanText.isNotEmpty) ...[
            // แบ่งเนื้อหาเป็นย่อหน้า
            ...cleanText
                .split('\n')
                .where((p) => p.trim().isNotEmpty)
                .map(
                  (paragraph) => Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      paragraph.trim(),
                      style: GoogleFonts.notoSansLao(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
          ],

          // แสดงรูปภาพที่ฝังในเนื้อหา
          if (embeddedImages.isNotEmpty) ...[
            SizedBox(height: 20),
            Text(
              'ຮູບພາບປະກອບຂ່າວ',
              style: GoogleFonts.notoSansLao(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF07325D),
              ),
            ),
            SizedBox(height: 16),
            ...embeddedImages.asMap().entries.map((entry) {
              final int index = entry.key;
              final String imageUrl = entry.value;

              return Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF07325D),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'ກຳລັງໂຫຼດຮູບພາບ...',
                                    style: GoogleFonts.notoSansLao(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.red[300],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'ບໍ່ສາມາດໂຫຼດຮູບພາບໄດ້',
                                  style: GoogleFonts.notoSansLao(
                                    fontSize: 12,
                                    color: Colors.red[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'URL: ${imageUrl.length > 50 ? imageUrl.substring(0, 50) + "..." : imageUrl}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 10,
                                    color: Colors.red[400],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ຮູບທີ່ ${index + 1}',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          SizedBox(height: 32),

          // Signature section (if needed)
          if (_news!.sectionTitle?.isNotEmpty == true) ...[
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ສະຖາບັນການທະນາຄານ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF07325D),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _news!.sectionTitle ?? '',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewsMetaInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Color(0xFF07325D)),
              SizedBox(width: 8),
              Text(
                'ວັນທີ: ${_formatDate(_news!.date.toString())}',
                style: GoogleFonts.notoSansLao(
                  fontSize: 14,
                  color: Color(0xFF07325D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                '${_news!.visits} ຄົນເບິ່ງ',
                style: GoogleFonts.notoSansLao(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF07325D), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ສອບຖາມຂໍ້ມູນເພີ່ມເຕີມທີ່ສະຖາບັນການທະນາຄານ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 14,
                    color: Color(0xFF07325D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: Colors.grey[300]),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ອັບເດດເມື່ອ: ${_formatDate(DateTime.now().toString())}',
                style: GoogleFonts.notoSansLao(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
