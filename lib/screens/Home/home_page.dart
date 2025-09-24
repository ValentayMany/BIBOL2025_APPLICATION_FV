// pages/Home_page.dart - Fixed Image Loading Version
import 'package:BIBOL/models/course/course_model.dart' show CourseModel;
import 'package:BIBOL/models/news/news_response.dart' show NewsResponse;
import 'package:BIBOL/models/topic/topic_model.dart' show Topic;
import 'package:BIBOL/screens/News/news_detail.dart';
import 'package:BIBOL/services/course/course_Service.dart';
import 'package:BIBOL/services/news/news_service.dart' show NewsService;
import 'package:BIBOL/widgets/custom_bottom_nav.dart';
import 'package:BIBOL/services/token/token_service.dart';
import 'package:BIBOL/widgets/banner/banner_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'
    show FontAwesomeIcons;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../services/auth/auth_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userInfo;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;

  // State สำหรับ courses
  List<CourseModel> _courses = [];
  bool _isCoursesLoading = true;
  String? _errorMessage;

  // State สำหรับ news
  List<Topic> _latestNews = [];
  bool _isNewsLoading = true;
  String? _newsErrorMessage;

  // Search controller
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _setupImageErrorHandling(); // ✅ เพิ่มการจัดการ Image Error
    _initializeComponents();
    _fetchCourses();
    _fetchLatestNews();
  }

  // ✅ เพิ่มการจัดการ Error สำหรับ Images
  void _setupImageErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // ซ่อน error ที่เกี่ยวกับ network images
      if (details.exception.toString().contains('HTTP request failed') ||
          details.exception.toString().contains('images.unsplash.com') ||
          details.exception.toString().contains('404') ||
          details.exception.toString().contains('NetworkImageLoadException')) {
        print('🖼️ Image loading error (ignored): ${details.exception}');
        return;
      }
      // แสดง error อื่นๆ ตามปกติ
      FlutterError.presentError(details);
    };
  }

  Future<void> _initializeComponents() async {
    try {
      _setupAnimations();
      await _checkLoginStatus();

      await Future.delayed(Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error initializing components: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return '';

    // ลบ HTML tags ทั้งหมด
    String stripped = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');

    // แทนที่ HTML entities
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

    // ลบช่องว่างที่เกินไป
    stripped = stripped.replaceAll(RegExp(r'\s+'), ' ').trim();

    return stripped;
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

  // โหลดคอร์สจาก API
  Future<void> _fetchCourses() async {
    try {
      final response = await CourseService.fetchCourses();
      if (mounted) {
        setState(() {
          _courses = response.courses;
          _isCoursesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'ດຶງຂໍ້ມູນບໍ່ສຳເລັດ';
          _isCoursesLoading = false;
        });
      }
    }
  }

  // โหลดข่าวล่าสุด (จำกัด 4 ตัว)
  Future<void> _fetchLatestNews() async {
    try {
      final response = await NewsService.getNews(limit: 4, page: 1);
      if (mounted) {
        setState(() {
          if (response.success && response.data.isNotEmpty) {
            _latestNews =
                response.data
                    .expand((newsModel) => newsModel.topics)
                    .take(4)
                    .toList();
          }
          _isNewsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _newsErrorMessage = 'ດຶງຂ່າວບໍ່ສຳເລັດ';
          _isNewsLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
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

      drawer: _buildDrawer(),
      body:
          _isLoading
              ? _buildLoadingScreen()
              : CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildSearchSection(),
                        _buildQuickStatsSection(),
                        _buildCoursesSection(),
                        _buildNewsSection(),
                        _buildQuickActionsSection(),
                        SizedBox(height: 100), // Space for bottom nav
                      ],
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Drawer UI
  Widget _buildDrawer() {
    return Drawer(
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
            child: SafeArea(
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
                        fontSize: 22,
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
                  _buildDrawerItem(Icons.person_rounded, 'ໂປຣໄຟລ', '/profile'),
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
    );
  }

  // Modern Sliver App Bar
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: Color(0xFF07325D),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern

              // Banner Slider
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: BannerSliderWidget(
                    height: 160,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 4),
                    showIndicators: true,
                    showNavigationButtons: false,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    margin: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      title: Text(
        'ສະຖາບັນການທະນາຄານ',
        style: GoogleFonts.notoSansLao(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
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
            ),
          )
        else
          Container(
            margin: EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/login');
                if (result == true) {
                  await _checkLoginStatus();
                }
              },
              child: Text(
                'ເຂົ້າສູ່ລະບົບ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Search Section
  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ຄົ້ນຫາຫຼັກສູດ ຫຼື ຂ່າວສານ...',
            hintStyle: GoogleFonts.notoSansLao(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.search, color: Color(0xFF07325D)),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: Icon(Icons.clear, color: Colors.grey[400]),
                    )
                    : Icon(Icons.tune, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          style: GoogleFonts.notoSansLao(fontSize: 14),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }

  // Quick Stats Section
  Widget _buildQuickStatsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: FontAwesomeIcons.graduationCap,
              title: 'ຫຼັກສູດ',
              value: '${_courses.length}',
              color: Color(0xFF07325D),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: _buildStatCard(
              icon: Icons.article,
              title: 'ຂ່າວສານ',
              value: '${_latestNews.length}+',
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: _buildStatCard(
              icon: Icons.people,
              title: 'ນັກຮຽນ',
              value: '1000+',
              color: Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.notoSansLao(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.notoSansLao(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Modern Courses Section with Horizontal Scroll
  Widget _buildCoursesSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ຫຼັກສູດການສຶກສາ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF07325D),
                      ),
                    ),
                    Text(
                      'ເລືອກຫຼັກສູດທີ່ເໝາະກັບທ່ານ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'ເບິ່ງທັງຫມົດ',
                    style: GoogleFonts.notoSansLao(
                      color: Color(0xFF07325D),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          _isCoursesLoading
              ? Container(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF07325D),
                    ),
                  ),
                ),
              )
              : Container(
                height: 180, // ปรับความสูงให้ตรงกับ card
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    double cardWidth = screenWidth < 400 ? 240 : 260;

                    return Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(right: 16),
                      child: _buildModernCourseCard(_courses[index]),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  // ✅ แก้ไข Course Card - เพิ่ม Error Handling สำหรับรูปภาพ
  Widget _buildModernCourseCard(CourseModel course) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;

        return Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/course-detail',
                  arguments: course,
                );
              },
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - ลดขนาดลง
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _buildCourseIcon(course),
                        ),
                        Spacer(),
                      ],
                    ),

                    SizedBox(height: 25),

                    // Course Title - จำกัดบรรทัด
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: GoogleFonts.notoSansLao(
                              fontSize: isSmallScreen ? 15 : 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Action Button - ลดขนาดลง
                    Container(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/course-detail',
                            arguments: course,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF07325D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_outlined, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'ເບິ່ງລາຍລະອຽດ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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

  // ✅ Helper method สำหรับสร้าง Course Icon ที่ปลอดภัย
  Widget _buildCourseIcon(CourseModel course) {
    // ตรวจสอบว่า icon เป็น URL หรือไม่
    if (course.icon != null &&
        course.icon!.isNotEmpty &&
        Uri.tryParse(course.icon!) != null &&
        course.icon!.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          course.icon!,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              FontAwesomeIcons.graduationCap,
              size: 18,
              color: Colors.white,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Icon(
              FontAwesomeIcons.graduationCap,
              size: 18,
              color: Colors.white,
            );
          },
        ),
      );
    }

    // Default icon
    return Icon(FontAwesomeIcons.graduationCap, size: 18, color: Colors.white);
  }

  // Featured News Section
  Widget _buildNewsSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ຂ່າວສານລ່າສຸດ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF07325D),
                      ),
                    ),
                    Text(
                      'ອັບເດດຂໍ້ມູນຂ່າວສານໃໝ່ລ່າສຸດ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/news');
                  },
                  child: Text(
                    'ເບິ່ງທັງຫມົດ',
                    style: GoogleFonts.notoSansLao(
                      color: Color(0xFF07325D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          _isNewsLoading
              ? Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF07325D),
                    ),
                  ),
                ),
              )
              : _latestNews.isEmpty
              ? Container(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'ບໍ່ມີຂ່າວສານໃໝ່',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Column(
                children: [
                  // Featured News (First news item)
                  if (_latestNews.isNotEmpty)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFeaturedNewsCard(_latestNews.first),
                    ),

                  SizedBox(height: 20),

                  // Other news items
                  if (_latestNews.length > 1)
                    Container(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _latestNews.length - 1,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 250,
                            margin: EdgeInsets.only(right: 16),
                            child: _buildCompactNewsCard(
                              _latestNews[index + 1],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
        ],
      ),
    );
  }

  // ✅ แก้ไข Featured News Card - เพิ่ม Error Handling
  Widget _buildFeaturedNewsCard(Topic news) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => NewsDetailPage(newsId: news.id.toString()),
              ),
            );
          },
          child: Row(
            children: [
              // Image section
              Container(
                width: 140,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: _buildNewsImage(news.photoFile),
                ),
              ),

              // Content section
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF07325D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ຂ່າວໃໝ່',
                              style: GoogleFonts.notoSansLao(
                                fontSize: 12,
                                color: Color(0xFF07325D),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${news.visits}',
                                style: GoogleFonts.notoSansLao(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        _stripHtmlTags(news.title),
                        style: GoogleFonts.notoSansLao(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          _stripHtmlTags(news.details),
                          style: GoogleFonts.notoSansLao(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF07325D),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'ອ່ານເພີ່ມ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: 12,
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
          ),
        ),
      ),
    );
  }

  // ✅ แก้ไข Compact News Card - เพิ่ม Error Handling
  Widget _buildCompactNewsCard(Topic news) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => NewsDetailPage(newsId: news.id.toString()),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: _buildNewsImage(news.photoFile, height: 100),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stripHtmlTags(news.title),
                        style: GoogleFonts.notoSansLao(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          _stripHtmlTags(news.details),
                          style: GoogleFonts.notoSansLao(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${news.visits}',
                            style: GoogleFonts.notoSansLao(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Color(0xFF07325D),
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

  // ✅ Helper method สำหรับสร้างรูปภาพข่าวที่ปลอดภัย
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
                  Color(0xFF07325D).withOpacity(0.7),
                  Color(0xFF0A4A73).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.article,
              size: height != null ? 30 : 60,
              color: Colors.white,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(color: Colors.grey[200]),
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

    // Default placeholder
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF07325D).withOpacity(0.7),
            Color(0xFF0A4A73).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.article,
        size: height != null ? 30 : 60,
        color: Colors.white,
      ),
    );
  }

  // Quick Actions Section
  Widget _buildQuickActionsSection() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ການດຳເນີນງານດ່ວນ',
            style: GoogleFonts.notoSansLao(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF07325D),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.phone,
                  title: 'ຕິດຕໍ່ເຮົາ',
                  subtitle: 'ສອບຖາມຂໍ້ມູນເພີ່ມເຕີມ',
                  color: Color(0xFF2E7D32),
                  onTap: () {
                    // Handle contact action
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.school,
                  title: 'ສະໝັກຮຽນ',
                  subtitle: 'ລົງທະບຽນຮຽນ',
                  color: Color(0xFFE65100),
                  onTap: () {
                    // Handle registration action
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Floating Action Button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Show quick menu or search
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder:
              (context) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 20),
                    ListTile(
                      leading: Icon(Icons.search, color: Color(0xFF07325D)),
                      title: Text('ຄົ້ນຫາ', style: GoogleFonts.notoSansLao()),
                      onTap: () {
                        Navigator.pop(context);
                        // Focus on search field
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.refresh, color: Color(0xFF07325D)),
                      title: Text(
                        'ໂຫຼດຂໍ້ມູນໃໝ່',
                        style: GoogleFonts.notoSansLao(),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _fetchCourses();
                        _fetchLatestNews();
                      },
                    ),
                  ],
                ),
              ),
        );
      },
      backgroundColor: Color(0xFF07325D),
      child: Icon(Icons.add, color: Colors.white),
    );
  }

  // Loading Screen
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            'ກຳລັງໂຫຼດ...',
            style: GoogleFonts.notoSansLao(
              color: Color(0xFF07325D),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
