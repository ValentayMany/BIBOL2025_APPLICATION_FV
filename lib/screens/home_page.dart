// pages/Home_page.dart
import 'package:BIBOL/models/course_model.dart' show CourseModel;
import 'package:BIBOL/models/news_respones.dart' show NewsResponse;
import 'package:BIBOL/models/topic_model.dart' show Topic;
import 'package:BIBOL/services/course_service.dart' show CourseService;
import 'package:BIBOL/services/news_service.dart' show NewsService;
import 'package:BIBOL/widgets/custom_bottom_nav.dart';
import 'package:BIBOL/services/token_service.dart';
import 'package:BIBOL/widgets/banner_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'
    show FontAwesomeIcons;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  // Helper function สำหรับลบ HTML tags

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

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _fetchCourses();
    _fetchLatestNews();
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

  // โหลดข่าวล่าสุด
  Future<void> _fetchLatestNews() async {
    try {
      final response = await NewsService.getNews(limit: 6, page: 1);
      if (mounted) {
        setState(() {
          if (response.success && response.data.isNotEmpty) {
            _latestNews =
                response.data
                    .expand((newsModel) => newsModel.topics)
                    .take(6)
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
      drawer: _buildDrawer(),
      body:
          _isLoading
              ? _buildLoadingScreen()
              : RefreshIndicator(
                color: Color(0xFF07325D),
                onRefresh: () async {
                  await Future.wait([_fetchCourses(), _fetchLatestNews()]);
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [_buildHeaderSection(), _buildContentSection()],
                  ),
                ),
              ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
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

  // Loading UI
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

  // Header Section
  Widget _buildHeaderSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: MediaQuery.of(context).size.width * 0.6,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: BannerSliderWidget(
                height: MediaQuery.of(context).size.width * 0.6,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 4),
                showIndicators: true,
                showNavigationButtons: false,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                margin: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  // Content Section (Courses + News)
  Widget _buildContentSection() {
    return Container(
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
          padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // หลักสูตรการศึกษา
              _buildCoursesSection(),

              SizedBox(height: 50),

              // ข่าวสารล่าสุด
              _buildNewsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Courses Section
  Widget _buildCoursesSection() {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Text(
                'ຫຼັກສູດການສຶກສາ',
                style: GoogleFonts.notoSansLao(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF07325D),
                ),
              ),
              Container(
                width: 80,
                height: 4,
                margin: EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),

        // Courses Grid
        _isCoursesLoading
            ? Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
                  strokeWidth: 3,
                ),
              ),
            )
            : LayoutBuilder(
              builder: (context, constraints) {
                // คำนวณจำนวนคอลัมน์ตามขนาดหน้าจอ
                int crossAxisCount = 2;
                if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 900) {
                  crossAxisCount = 4;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _courses.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return _buildCourseCard(course);
                  },
                );
              },
            ),
      ],
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return GestureDetector(
      onTap: () {
        // ไปหน้า detail ของ course
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // ไปหน้า detail ของ course
            },
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon หรือรูป
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child:
                        course.icon != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                course.icon!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Icon(
                                      FontAwesomeIcons.graduationCap,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                              ),
                            )
                            : Icon(Icons.book, color: Colors.white, size: 30),
                  ),
                  SizedBox(height: 16),

                  // ชื่อหลักสูตร
                  Text(
                    course.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansLao(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // รายละเอียด
                  Text(
                    _stripHtmlTags(course.details),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansLao(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // News Section ที่ปรับปรุงใหม่
  Widget _buildNewsSection() {
    return Column(
      children: [
        // หัวข้อข่าวสาร
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ຂ່າວສານລ່າສຸດ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07325D),
                  ),
                ),
                Container(
                  width: 80,
                  height: 4,
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/news');
              },
              // icon: Icon(
              //   Icons.arrow_forward_ios,
              //   size: 16,
              //   color: Color(0xFF07325D),
              // ),
              label: Text(
                'ເບິ່ງທັງຫມົດ',
                style: GoogleFonts.notoSansLao(
                  color: Color(0xFF07325D),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 30),

        // รายการข่าวแบบ Grid เหมือน Courses
        _isNewsLoading
            ? Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
                  strokeWidth: 3,
                ),
              ),
            )
            : _latestNews.isEmpty
            ? Container(
              padding: EdgeInsets.all(60),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.article_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ບໍ່ມີຂ່າວສານໃໝ່',
                    style: GoogleFonts.notoSansLao(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
            : LayoutBuilder(
              builder: (context, constraints) {
                // คำนวณจำนวนคอลัมน์ตามขนาดหน้าจอ
                int crossAxisCount = 2;
                if (constraints.maxWidth > 600) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 900) {
                  crossAxisCount = 4;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _latestNews.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final news = _latestNews[index];
                    return _buildNewsCard(news);
                  },
                );
              },
            ),
      ],
    );
  }

  Widget _buildNewsCard(Topic news) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pushNamed(context, '/news/detail', arguments: news.id);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // รูปข่าว
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.grey[200],
                ),
                child: Stack(
                  children: [
                    if (news.photoFile.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.network(
                          news.photoFile,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                width: double.infinity,
                                height: 120,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                              ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF07325D).withOpacity(0.8),
                              Color(0xFF0A4A73).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Icon(
                          Icons.article,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),

                    // Badge สำหรับวันที่
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${news.date.day}/${news.date.month}',
                          style: GoogleFonts.notoSansLao(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // เนื้อหาข่าว
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // หัวข้อข่าว
                      Text(
                        _stripHtmlTags(news.title),
                        style: GoogleFonts.notoSansLao(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF07325D),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 8),

                      // รายละเอียดข่าว
                      Expanded(
                        child: Text(
                          _stripHtmlTags(news.details),
                          style: GoogleFonts.notoSansLao(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(height: 12),

                      // ข้อมูลเพิ่มเติมและปุ่ม
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
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          Spacer(),
                          Container(
                            height: 28,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/news/detail',
                                  arguments: news.id,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF07325D),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: Text(
                                'ອ່ານເພີ່ມ',
                                style: GoogleFonts.notoSansLao(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
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
}
