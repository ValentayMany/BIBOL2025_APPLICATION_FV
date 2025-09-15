import 'package:auth_flutter_api/models/topic_model.dart';
import 'package:auth_flutter_api/widgets/custom_bottom_nav.dart';
import 'package:auth_flutter_api/services/token_service.dart';
import 'package:auth_flutter_api/services/news_service.dart';
import 'package:auth_flutter_api/models/news_response.dart';
import 'package:auth_flutter_api/models/news_model.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  Timer? _carouselTimer;
  int _carouselIndex = 0;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userInfo;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ✅ แก้ไข News data variables
  List<Topic> _newsList = [];
  bool _isLoadingNews = true;
  String? _newsError;
  int _newsRetryCount = 0;
  static const int MAX_RETRY = 3;

  final List<String> _carouselItems = [
    'assets/images/image52.png',
    'assets/images/LOGO.png',
    'assets/images/image52.png',
    'assets/images/LOGO.png',
  ];

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  // ✅ แก้ไข: แยกการ initialize ออกมา
  Future<void> _initializeComponents() async {
    try {
      _setupAnimations();
      _setupCarousel();

      // Load data concurrently
      await Future.wait([_checkLoginStatus(), _loadNews()]);
    } catch (e) {
      print('❌ Error initializing components: $e');
      _handleInitializationError(e);
    }
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _setupCarousel() {
    _pageController = PageController(initialPage: 0);
    _carouselTimer = Timer.periodic(Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_carouselIndex + 1) % _carouselItems.length;
      _pageController.animateToPage(
        next,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _handleInitializationError(dynamic error) {
    if (mounted) {
      setState(() {
        _newsError = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $error';
        _isLoadingNews = false;
      });
    }
  }

  // ✅ แก้ไข _loadNews method ให้มีประสิทธิภาพมากขึ้น
  Future<void> _loadNews() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoadingNews = true;
        _newsError = null;
        _newsRetryCount = 0;
      });

      print('🔄 Loading news... (attempt ${_newsRetryCount + 1})');

      // Test connection first
      final isConnected = await NewsService.testConnection();
      if (!isConnected) {
        throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
      }

      final newsResponse = await NewsService.getNews(limit: 10, page: 1);

      if (!mounted) return;

      print('📰 News Response Success: ${newsResponse.success}');
      print('📰 News Data Length: ${newsResponse.data.length}');

      if (newsResponse.success) {
        await _processNewsData(newsResponse);
      } else {
        throw Exception(newsResponse.message ?? 'ไม่สามารถโหลดข่าวได้');
      }
    } catch (e) {
      print('❌ Error loading news: $e');
      await _handleNewsError(e);
    }
  }

  Future<void> _processNewsData(NewsResponse newsResponse) async {
    List<Topic> allTopics = [];

    try {
      // ✅ แก้ไข: ตรวจสอบข้อมูลให้ครอบคลุมมากขึ้น
      if (newsResponse.data.isNotEmpty) {
        for (final newsModel in newsResponse.data) {
          if (newsModel.topics.isNotEmpty) {
            allTopics.addAll(newsModel.topics);
            print(
              '📰 Added ${newsModel.topics.length} topics from ${newsModel.sectionTitle}',
            );
          }
        }
      }

      // ✅ กรองและเรียงข่าวตามวันที่
      allTopics =
          allTopics
              .where(
                (topic) =>
                    topic.title != null &&
                    topic.title!.isNotEmpty &&
                    topic.id != null &&
                    topic.id.isNotEmpty,
              )
              .toList();

      if (mounted) {
        setState(() {
          _newsList = allTopics.take(6).toList();
          _isLoadingNews = false;
          _newsError = null;
        });

        print('📰 Final news list length: ${_newsList.length}');

        // แสดงรายการข่าวที่โหลดได้
        for (int i = 0; i < _newsList.length; i++) {
          print(
            '📰 News $i: ${_newsList[i].title.substring(0, _newsList[i].title.length > 50 ? 50 : _newsList[i].title.length)}...',
          );
        }
      }
    } catch (e) {
      print('❌ Error processing news data: $e');
      throw e;
    }
  }

  Future<void> _handleNewsError(dynamic error) async {
    if (!mounted) return;

    _newsRetryCount++;
    final errorMessage = _getErrorMessage(error);

    if (_newsRetryCount < MAX_RETRY) {
      print('🔄 Retrying news load... (${_newsRetryCount + 1}/$MAX_RETRY)');
      await Future.delayed(Duration(seconds: _newsRetryCount * 2));
      return _loadNews();
    }

    setState(() {
      _newsError = errorMessage;
      _isLoadingNews = false;
    });
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('socket') || errorStr.contains('network')) {
      return 'ไม่สามารถเชื่อมต่อกับอินเทอร์เน็ตได้';
    } else if (errorStr.contains('timeout')) {
      return 'หมดเวลาในการเชื่อมต่อ กรุณาลองใหม่';
    } else if (errorStr.contains('format') || errorStr.contains('parse')) {
      return 'ข้อมูลที่ได้รับไม่ถูกต้อง';
    } else if (errorStr.contains('404')) {
      return 'ไม่พบข้อมูลข่าวสาร';
    } else if (errorStr.contains('500')) {
      return 'เซิร์ฟเวอร์มีปัญหา กรุณาลองใหม่ภายหลัง';
    }

    return 'เกิดข้อผิดพลาดในการโหลดข่าว: ${error.toString()}';
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await TokenService.isLoggedIn();
      final userInfo = await TokenService.getUserInfo();

      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _userInfo = userInfo;
        });
      }
    } catch (e) {
      print('❌ Error checking login status: $e');
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/news');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/gallery');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/about');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Color(0xFF07325D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'ອອກຈາກລະບົບ',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'ທ່ານຕ້ອງການອອກຈາກລະບົບບໍ່?',
              style: GoogleFonts.notoSansLao(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ຍົກເລີກ',
                  style: GoogleFonts.notoSansLao(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await TokenService.clearAll();
                  await _checkLoginStatus();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 10),
                            Text('ອອກຈາກລະບົບສຳເລັດ'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'ອອກຈາກລະບົບ',
                  style: GoogleFonts.notoSansLao(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildGradientCard({
    required String content,
    required List<Color> gradientColors,
    required IconData icon,
  }) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                SizedBox(height: 12),
                Expanded(
                  child: Text(
                    content,
                    style: GoogleFonts.notoSansLao(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ แก้ไข _buildNewsCard ให้ทำงานได้ดีขึ้น
  Widget _buildNewsCard(int index) {
    if (index >= _newsList.length) {
      return _buildEmptyNewsCard();
    }

    final topic = _newsList[index];

    return GestureDetector(
      onTap: () {
        if (topic.id.isNotEmpty) {
          Navigator.pushNamed(context, '/news-detail', arguments: topic.id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.grey[100],
                ),
                child: _buildNewsImage(topic),
              ),
            ),

            // News content
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      topic.title.isNotEmpty ? topic.title : 'ไม่มีหัวข้อ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF07325D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6),

                    // Content
                    Expanded(
                      child: Text(
                        topic.details.isNotEmpty
                            ? topic.details
                            : 'ไม่มีรายละเอียด',
                        style: GoogleFonts.notoSansLao(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Date and views
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(topic.date),
                          style: GoogleFonts.notoSansLao(
                            fontSize: 9,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (topic.visits > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 10,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 2),
                              Text(
                                '${topic.visits}',
                                style: GoogleFonts.notoSansLao(
                                  fontSize: 9,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
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
    );
  }

  Widget _buildNewsImage(Topic topic) {
    if (topic.photoFile.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          topic.photoFile,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error loading image: ${topic.photoFile}');
            return _buildDefaultNewsImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
              ),
            );
          },
        ),
      );
    }
    return _buildDefaultNewsImage();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'ວັນນີ້';
    } else if (difference.inDays == 1) {
      return 'ມື້ວານ';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ວັນກ່ອນ';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildDefaultNewsImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Icon(
          Icons.article_rounded,
          size: 40,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildEmptyNewsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 40, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              'ບໍ່ມີຂ່າວ',
              style: GoogleFonts.notoSansLao(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 8,
                    width: double.infinity * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 8,
                    width: double.infinity * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    String? route, {
    VoidCallback? onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : Color(0xFF07325D),
          size: 24,
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSansLao(
            color: isLogout ? Colors.red : Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap:
            onTap ??
            () {
              Navigator.pop(context);
              if (route != null) {
                Navigator.pushReplacementNamed(context, route);
              }
            },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Color(0xFF07325D),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ສະຖາບັນການທະນາຄານ',
          style: GoogleFonts.notoSansLao(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isLoggedIn)
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _handleLogout,
                icon: Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'ອອກຈາກລະບົບ',
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            )
          else
            Container(
              margin: EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/login');
                  if (result == true) {
                    await _checkLoginStatus();
                  }
                },
                label: Text(
                  'ເຂົ້າສູ່ລະບົບ',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isLoggedIn ? Icons.person : Icons.menu_book_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _isLoggedIn ? 'ສະບາຍດີ' : 'ເມນູ',
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isLoggedIn && _userInfo != null) ...[
                      Text(
                        "${_userInfo!['first_name'] ?? ''} ${_userInfo!['last_name'] ?? ''}"
                            .trim(),
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_userInfo!['student_id'] != null)
                        Text(
                          'ລະຫັດ: ${_userInfo!['student_id']}',
                          style: GoogleFonts.notoSansLao(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ] else if (!_isLoggedIn)
                      Text(
                        'ຍິນດີຕ້ອນຮັບ',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildDrawerItem(Icons.home_rounded, 'ໜ້າຫຼັກ', '/home'),
                  _buildDrawerItem(Icons.article_rounded, 'ຂ່າວສານ', '/news'),
                  _buildDrawerItem(
                    Icons.photo_library_rounded,
                    'ຄັງຮູບ',
                    '/gallery',
                  ),
                  _buildDrawerItem(Icons.info_rounded, 'ກ່ຽວກັບ', '/about'),
                  Divider(color: Colors.grey[300], thickness: 1, height: 32),
                  if (_isLoggedIn) ...[
                    _buildDrawerItem(
                      Icons.person_rounded,
                      'ໂປຣໄຟລ',
                      '/profile',
                    ),
                    _buildDrawerItem(
                      Icons.logout_rounded,
                      'ອອກຈາກລະບົບ',
                      null,
                      onTap: _handleLogout,
                      isLogout: true,
                    ),
                  ] else
                    _buildDrawerItem(
                      Icons.login_rounded,
                      'ເຂົ້າສູ່ລະບົບ',
                      null,
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.pushNamed(
                          context,
                          '/login',
                        );
                        if (result == true) {
                          await _checkLoginStatus();
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNews,
        color: Color(0xFF07325D),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header Section with Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    // Enhanced Carousel
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: EdgeInsets.all(20),
                        height: 280,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: _carouselItems.length,
                                onPageChanged: (i) {
                                  setState(() {
                                    _carouselIndex = i;
                                  });
                                },
                                itemBuilder: (context, i) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      _carouselItems[i],
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _carouselItems.length,
                                    (i) {
                                      final active = i == _carouselIndex;
                                      return AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        width: active ? 24 : 8,
                                        height: 8,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              active
                                                  ? Colors.white
                                                  : Colors.white54,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          boxShadow:
                                              active
                                                  ? [
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withOpacity(0.5),
                                                      blurRadius: 8,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ]
                                                  : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              // Content Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'ຫຼັກສູດການສຶກສາ',
                                style: GoogleFonts.notoSansLao(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF07325D),
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 4,
                                margin: EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF07325D),
                                      Color(0xFF0A4A73),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),

                        // Course Cards
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                          children: [
                            _buildGradientCard(
                              content:
                                  'ບັນຊີ\nສາຂາບັນຊີ\nການຈັດການການເງິນ\nການຈັດການທຸລະກິດ',
                              gradientColors: [
                                Color(0xFF667eea),
                                Color(0xFF764ba2),
                              ],
                              icon: Icons.account_balance_wallet,
                            ),
                            _buildGradientCard(
                              content:
                                  'ການທະນາຄານ\nການລົງທຶນ\nການປະກັນໄພ\nການຈັດການຄວາມສ່ຽງ',
                              gradientColors: [
                                Color(0xFF11998e),
                                Color(0xFF38ef7d),
                              ],
                              icon: Icons.account_balance,
                            ),
                            _buildGradientCard(
                              content:
                                  'ວິສາຫະກິດສາດ\nເສດຖະກິດ\nການຕະຫຼາດ\nການຄ້າສາກົນ',
                              gradientColors: [
                                Color(0xFFee0979),
                                Color(0xFFff6a00),
                              ],
                              icon: Icons.trending_up,
                            ),
                            _buildGradientCard(
                              content:
                                  'ເທັກໂນໂລຢີສາລະສະໜເທດ\nລະບົບສາລະສະໜເທດ\nການຄຸ້ມຄອງຂໍ້ມູນ\nການພັດທະນາເວັບໄຊ',
                              gradientColors: [
                                Color(0xFF4facfe),
                                Color(0xFF00f2fe),
                              ],
                              icon: Icons.computer,
                            ),
                          ],
                        ),

                        SizedBox(height: 40),

                        // News Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ຂ່າວສານຫຼ້າສຸດ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF07325D),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/news');
                              },
                              child: Text(
                                'ເບິ່ງທັງໝົດ',
                                style: GoogleFonts.notoSansLao(
                                  color: Color(0xFF07325D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // ✅ แก้ไข News Grid Section
                        if (_isLoadingNews)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: 6,
                            itemBuilder:
                                (context, index) => _buildLoadingCard(),
                          )
                        else if (_newsError != null)
                          Container(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'ບໍ່ສາມາດໂຫຼດຂ່າວໄດ້',
                                    style: GoogleFonts.notoSansLao(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      _newsError!,
                                      style: GoogleFonts.notoSansLao(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _newsRetryCount = 0;
                                      _loadNews();
                                    },
                                    icon: Icon(Icons.refresh),
                                    label: Text(
                                      'ລອງໃໝ່',
                                      style: GoogleFonts.notoSansLao(),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF07325D),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (_newsList.isEmpty)
                          Container(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.article_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'ຍັງບໍ່ມີຂ່າວ',
                                    style: GoogleFonts.notoSansLao(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'ກະລຸນາກັບມາກວດເບິ່ງໃນພາຍຫຼັງ',
                                    style: GoogleFonts.notoSansLao(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount:
                                _newsList.length > 6 ? 6 : _newsList.length,
                            itemBuilder:
                                (context, index) => _buildNewsCard(index),
                          ),

                        SizedBox(height: 40),

                        // Contact Info Section
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSansLao(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                content,
                style: GoogleFonts.notoSansLao(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension on int {
  bool get isNotEmpty => '$toString'.isNotEmpty;
}
