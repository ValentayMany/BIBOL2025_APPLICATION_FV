// pages/Home_page.dart - Updated with News-style Header
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
import 'dart:ui';

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

  // Add GlobalKey for scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Theme colors - Same as News Page
  final primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
  );

  @override
  void initState() {
    super.initState();
    _setupImageErrorHandling();
    _initializeComponents();
    _fetchCourses();
    _fetchLatestNews();
  }

  void _setupImageErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('HTTP request failed') ||
          details.exception.toString().contains('images.unsplash.com') ||
          details.exception.toString().contains('404') ||
          details.exception.toString().contains('NetworkImageLoadException')) {
        print('🖼️ Image loading error (ignored): ${details.exception}');
        return;
      }
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (isSelected) ...[
                  Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFF8FAFF),
      drawer: _buildModernDrawer(),
      body:
          _isLoading
              ? _buildLoadingScreen()
              : CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  // Modern Header Section - Same style as News Page
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF07325D).withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            // Header with drawer button and notifications
                            Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.menu_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            _scaffoldKey.currentState
                                                ?.openDrawer();
                                          },
                                        ),
                                      ),
                                      Spacer(),
                                      if (_isLoggedIn)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.power_settings_new,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: _handleLogout,
                                            tooltip: 'ອອກຈາກລະບົບ',
                                          ),
                                        )
                                      else
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: TextButton(
                                            onPressed: () async {
                                              final result =
                                                  await Navigator.pushNamed(
                                                    context,
                                                    '/login',
                                                  );
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
                                  ),
                                  SizedBox(height: 8),

                                  // Logo and title
                                  TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 800),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: 0.8 + (0.2 * value),
                                        child: Opacity(
                                          opacity: value,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 90,
                                                height: 90,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.15),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    width: 3,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 20,
                                                      offset: Offset(0, 10),
                                                    ),
                                                  ],
                                                ),
                                                child: Image(
                                                  image: AssetImage(
                                                    'assets/images/LOGO.png',
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 15),
                                              Text(
                                                'ສະຖາບັນການທະນາຄານ',
                                                style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),

                                              Text(
                                                '🎊ຍິນດີຕ້ອນຮັບ🎊',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main Content
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

  // Modern Drawer (Same as News Page)
  Widget _buildModernDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child:
                          _isLoggedIn
                              ? Icon(
                                Icons.account_circle_rounded,
                                color: Color(0xFF07325D),
                                size: 50,
                              )
                              : Icon(
                                Icons.menu_book_rounded,
                                color: Color(0xFF07325D),
                                size: 50,
                              ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _isLoggedIn ? 'ສະບາຍດີ!' : 'ສະບາຍດີ!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_isLoggedIn && _userInfo != null) ...[
                      Text(
                        "${_userInfo!['first_name'] ?? ''} ${_userInfo!['last_name'] ?? ''}"
                            .trim(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_userInfo!['student_id'] != null)
                        Text(
                          'ລະຫັດ: ${_userInfo!['student_id']}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                    ] else
                      Text(
                        'ຍິນດີຕ້ອນຮັບ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildDrawerItem(
                        icon: Icons.home_rounded,
                        title: 'ໜ້າຫຼັກ',
                        isSelected: true,
                        onTap: () => Navigator.pop(context),
                      ),
                      _buildDrawerItem(
                        icon: Icons.newspaper_rounded,
                        title: 'ຂ່າວສານ',
                        onTap:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/news',
                            ),
                      ),
                      _buildDrawerItem(
                        icon: Icons.photo_library_rounded,
                        title: 'ຮູບພາບ',
                        onTap:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/gallery',
                            ),
                      ),
                      _buildDrawerItem(
                        icon: Icons.info_rounded,
                        title: 'ກ່ຽວກັບ',
                        onTap:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/about',
                            ),
                      ),
                      if (_isLoggedIn)
                        _buildDrawerItem(
                          icon: Icons.person_rounded,
                          title: 'ໂປຣໄຟລ໌',
                          onTap:
                              () => Navigator.pushReplacementNamed(
                                context,
                                '/profile',
                              ),
                        ),
                      SizedBox(height: 20),
                      Divider(color: Colors.white.withOpacity(0.3)),
                      SizedBox(height: 20),
                      _buildDrawerItem(
                        icon: Icons.settings_rounded,
                        title: 'ຕັ້ງຄ່າ',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.help_rounded,
                        title: 'ຊ່ວຍເຫຼືອ',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    if (_isLoggedIn)
                      Container(
                        width: double.infinity,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleLogout,
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'ອອກຈາກລະບົບ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
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
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.login_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'ເຂົ້າສູ່ລະບົບ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
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
    );
  }

  // Search Section
  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'ຄົ້ນຫາຫຼັກສູດ ຫຼື ຂ່າວສານ...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF07325D),
                      size: 26,
                    ),
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? Container(
                            padding: EdgeInsets.all(8),
                            child: IconButton(
                              icon: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey[600],
                                  size: 18,
                                ),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                ),
              ),
            ),
          ),
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
                height: 180,
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

  Widget _buildCourseIcon(CourseModel course) {
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
                  if (_latestNews.isNotEmpty)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFeaturedNewsCard(_latestNews.first),
                    ),

                  SizedBox(height: 20),

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
