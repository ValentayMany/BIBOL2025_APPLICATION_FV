// pages/Home_page.dart - Enhanced Mobile Responsive Version
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

  // Theme colors
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

  // Enhanced Responsive helper methods
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  // More comprehensive device categorization
  bool get _isExtraSmallScreen => _screenWidth < 320; // iPhone SE gen 1
  bool get _isSmallScreen => _screenWidth < 375; // iPhone SE gen 2/3
  bool get _isMediumScreen => _screenWidth < 414; // iPhone 8 Plus
  bool get _isLargeScreen => _screenWidth < 480; // Small tablets
  bool get _isTablet => _screenWidth >= 600;

  bool get _isShortScreen => _screenHeight < 667; // iPhone SE
  bool get _isTallScreen => _screenHeight > 812; // iPhone X and newer

  // Dynamic padding based on screen size
  double get _basePadding {
    if (_isExtraSmallScreen) return 10.0;
    if (_isSmallScreen) return 12.0;
    if (_isMediumScreen) return 16.0;
    if (_isTablet) return 24.0;
    return 20.0;
  }

  double get _smallPadding => _basePadding * 0.75;
  double get _largePadding => _basePadding * 1.5;

  // Dynamic font sizes
  double get _titleFontSize {
    if (_isExtraSmallScreen) return 16.0;
    if (_isSmallScreen) return 18.0;
    if (_isMediumScreen) return 22.0;
    if (_isTablet) return 28.0;
    return 24.0;
  }

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
                fontSize: _titleFontSize * 0.8,
              ),
            ),
            content: Text(
              'ທ່ານຕ້ອງການອອກຈາກລະບົບບໍ່?',
              style: GoogleFonts.notoSansLao(
                color: Colors.white70,
                fontSize: _bodyFontSize,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ຍົກເລີກ',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.white70,
                    fontSize: _captionFontSize,
                  ),
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
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'ອອກຈາກລະບົບສຳເລັດ',
                                style: GoogleFonts.notoSansLao(
                                  fontSize: _captionFontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.all(_basePadding),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'ອອກຈາກລະບົບ',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.white,
                    fontSize: _captionFontSize,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFF07325D),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFF8FAFF),
      drawer: _buildModernDrawer(),
      extendBodyBehindAppBar: true,
      body:
          _isLoading
              ? _buildLoadingScreen()
              : Container(
                child: SafeArea(
                  top: false,
                  child: Container(
                    color: Color(0xFFF8FAFF),
                    child: CustomScrollView(
                      physics: BouncingScrollPhysics(),
                      slivers: [
                        _buildHeaderSection(),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              _buildSearchSection(),
                              _buildQuickStatsSection(),
                              _buildCoursesSection(),
                              _buildNewsSection(),
                              _buildQuickActionsSection(),
                              SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // Enhanced Header Section
  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          gradient: primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(_basePadding * 2),
            bottomRight: Radius.circular(_basePadding * 2),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF07325D).withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(_basePadding),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildHeaderButton(
                        icon: Icons.menu_rounded,
                        onPressed:
                            () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      Spacer(),
                      if (_isLoggedIn)
                        _buildHeaderButton(
                          icon: Icons.power_settings_new,
                          onPressed: _handleLogout,
                          tooltip: 'ອອກຈາກລະບົບ',
                        )
                      else
                        _buildLoginButton(),
                    ],
                  ),
                  SizedBox(height: _smallPadding),
                  _buildLogoSection(),
                ],
              ),
            ),
            SizedBox(height: _basePadding),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    final buttonSize =
        _isExtraSmallScreen
            ? 36.0
            : _isSmallScreen
            ? 40.0
            : 44.0;
    final iconSize = buttonSize * 0.5;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(buttonSize * 0.36),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: iconSize),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildLoginButton() {
    final buttonHeight =
        _isExtraSmallScreen
            ? 36.0
            : _isSmallScreen
            ? 40.0
            : 44.0;
    final buttonWidth =
        _isExtraSmallScreen
            ? 90.0
            : _isSmallScreen
            ? 100.0
            : 120.0;

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(buttonHeight * 0.36),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: TextButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/login');
          if (result == true) {
            await _checkLoginStatus();
          }
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: _smallPadding),
          minimumSize: Size(buttonWidth, buttonHeight),
        ),
        child: FittedBox(
          child: Text(
            'ເຂົ້າສູ່ລະບົບ',
            style: GoogleFonts.notoSansLao(
              color: Colors.white,
              fontSize: _captionFontSize * 0.9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final logoSize =
            _isExtraSmallScreen
                ? 50.0
                : _isSmallScreen
                ? 60.0
                : _isMediumScreen
                ? 70.0
                : _isTablet
                ? 90.0
                : 80.0;

        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Column(
              children: [
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(logoSize * 0.15),
                    child: Image.asset(
                      'assets/images/LOGO.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: _smallPadding),
                FittedBox(
                  child: Text(
                    'ສະຖາບັນການທະນາຄານ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: _titleFontSize * 1.2,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                FittedBox(
                  child: Text(
                    '🎊ຍິນດີຕ້ອນຮັບ🎊',
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Enhanced Modern Drawer
  Widget _buildModernDrawer() {
    final drawerWidth =
        _screenWidth *
        (_isExtraSmallScreen
            ? 0.9
            : _isSmallScreen
            ? 0.85
            : 0.8);

    return Drawer(
      backgroundColor: Colors.transparent,
      width: drawerWidth,
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
              _buildDrawerHeader(),
              Expanded(child: _buildDrawerMenu()),
              _buildDrawerFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    final avatarSize =
        _isExtraSmallScreen
            ? 45.0
            : _isShortScreen
            ? 55.0
            : _isTablet
            ? 85.0
            : 75.0;
    final maxTextWidth =
        _screenWidth *
        (_isExtraSmallScreen
            ? 0.7
            : _isSmallScreen
            ? 0.65
            : 0.6);

    return Container(
      padding: EdgeInsets.all(_basePadding),
      child: Column(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
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
            child: Icon(
              _isLoggedIn
                  ? Icons.account_circle_rounded
                  : Icons.menu_book_rounded,
              color: Color(0xFF07325D),
              size: avatarSize * 0.6,
            ),
          ),
          SizedBox(height: _smallPadding),
          FittedBox(
            child: Text(
              'ສະບາຍດີ!',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: _titleFontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (_isLoggedIn && _userInfo != null) ...[
            SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(maxWidth: maxTextWidth),
              child: Column(
                children: [
                  Text(
                    "${_userInfo!['first_name'] ?? ''} ${_userInfo!['last_name'] ?? ''}"
                        .trim(),
                    style: GoogleFonts.notoSansLao(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_userInfo!['student_id'] != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'ລະຫັດ: ${_userInfo!['student_id']}',
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: _captionFontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ] else
            Container(
              constraints: BoxConstraints(maxWidth: maxTextWidth),
              child: Text(
                'ຍິນດີຕ້ອນຮັບ',
                style: GoogleFonts.notoSansLao(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: _bodyFontSize,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerMenu() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _smallPadding),
      child: SingleChildScrollView(
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
              onTap: () => Navigator.pushReplacementNamed(context, '/news'),
            ),
            _buildDrawerItem(
              icon: Icons.photo_library_rounded,
              title: 'ຮູບພາບ',
              onTap: () => Navigator.pushReplacementNamed(context, '/gallery'),
            ),
            _buildDrawerItem(
              icon: Icons.info_rounded,
              title: 'ກ່ຽວກັບ',
              onTap: () => Navigator.pushReplacementNamed(context, '/about'),
            ),
            if (_isLoggedIn)
              _buildDrawerItem(
                icon: Icons.person_rounded,
                title: 'ໂປຣໄຟລ໌',
                onTap:
                    () => Navigator.pushReplacementNamed(context, '/profile'),
              ),
            Container(
              margin: EdgeInsets.symmetric(vertical: _smallPadding),
              child: Divider(color: Colors.white.withOpacity(0.3)),
            ),
            _buildDrawerItem(
              icon: Icons.settings_rounded,
              title: 'ຕັ້ງຄ່າ',
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.help_rounded,
              title: 'ຊ່ວຍເຫຼືອ',
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: _basePadding),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final itemHeight =
        _isExtraSmallScreen
            ? 44.0
            : _isSmallScreen
            ? 48.0
            : 52.0;
    final iconSize =
        _isExtraSmallScreen
            ? 16.0
            : _isSmallScreen
            ? 18.0
            : 20.0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: _isExtraSmallScreen ? 3 : 5),
      constraints: BoxConstraints(minHeight: itemHeight),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: _smallPadding,
              vertical: _smallPadding * 0.8,
            ),
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
                Icon(icon, color: Colors.white, size: iconSize),
                SizedBox(width: _smallPadding),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSansLao(
                      color: Colors.white,
                      fontSize: _bodyFontSize,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: 8),
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

  Widget _buildDrawerFooter() {
    final buttonHeight =
        _isExtraSmallScreen
            ? 40.0
            : _isSmallScreen
            ? 44.0
            : 48.0;

    return Container(
      padding: EdgeInsets.all(_basePadding),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 280, minHeight: buttonHeight),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                _isLoggedIn
                    ? _handleLogout
                    : () async {
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
                horizontal: _smallPadding,
                vertical: _smallPadding * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                    color: Colors.white,
                    size:
                        _isExtraSmallScreen
                            ? 14.0
                            : _isSmallScreen
                            ? 16.0
                            : 18.0,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        _isLoggedIn ? 'ອອກຈາກລະບົບ' : 'ເຂົ້າສູ່ລະບົບ',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: _captionFontSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Search Section
  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _basePadding,
        vertical: _basePadding,
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
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
                onChanged: (value) => setState(() {}),
                style: GoogleFonts.notoSansLao(fontSize: _bodyFontSize),
                decoration: InputDecoration(
                  hintText:
                      _isExtraSmallScreen
                          ? 'ຄົ້ນຫາ...'
                          : _isSmallScreen
                          ? 'ຄົ້ນຫາຫຼັກສູດ...'
                          : 'ຄົ້ນຫາຫຼັກສູດ ຫຼື ຂ່າວສານ...',
                  hintStyle: GoogleFonts.notoSansLao(
                    color: Colors.grey[500],
                    fontSize: _bodyFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    padding: EdgeInsets.all(_smallPadding * 0.8),
                    child: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF07325D),
                      size:
                          _isExtraSmallScreen
                              ? 18.0
                              : _isSmallScreen
                              ? 20.0
                              : 26.0,
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
                                  size:
                                      _isExtraSmallScreen
                                          ? 10.0
                                          : _isSmallScreen
                                          ? 12.0
                                          : 16.0,
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
                    horizontal: _smallPadding,
                    vertical: _isExtraSmallScreen ? 10.0 : _smallPadding,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Quick Stats Section
  Widget _buildQuickStatsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _basePadding, vertical: 10),
      child:
          _isExtraSmallScreen || _isSmallScreen
              ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: FontAwesomeIcons.graduationCap,
                          title: 'ຫຼັກສູດ',
                          value: '${_courses.length}',
                          color: Color(0xFF07325D),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.article,
                          title: 'ຂ່າວສານ',
                          value: '${_latestNews.length}+',
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildStatCard(
                    icon: Icons.people,
                    title: 'ນັກຮຽນ',
                    value: '1000+',
                    color: Color(0xFFE65100),
                  ),
                ],
              )
              : Row(
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
    final cardPadding = _isExtraSmallScreen ? 8.0 : _smallPadding;
    final iconSize =
        _isExtraSmallScreen
            ? 14.0
            : _isSmallScreen
            ? 16.0
            : _isTablet
            ? 26.0
            : 22.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
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
            padding: EdgeInsets.all(cardPadding * 0.8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: iconSize, color: color),
          ),
          SizedBox(height: cardPadding * 0.8),
          FittedBox(
            child: Text(
              value,
              style: GoogleFonts.notoSansLao(
                fontSize: _titleFontSize * 0.8,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: 4),
          FittedBox(
            child: Text(
              title,
              style: GoogleFonts.notoSansLao(
                fontSize: _captionFontSize,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Courses Section
  Widget _buildCoursesSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _basePadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          'ຫຼັກສູດການສຶກສາ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: _titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF07325D),
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ເລືອກຫຼັກສູດທີ່ເໝາະກັບທ່ານ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: _captionFontSize,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'ເບິ່ງທັງຫມົດ',
                    style: GoogleFonts.notoSansLao(
                      color: Color(0xFF07325D),
                      fontWeight: FontWeight.w600,
                      fontSize: _captionFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          _isCoursesLoading
              ? Container(
                height:
                    _isExtraSmallScreen
                        ? 140.0
                        : _isSmallScreen
                        ? 160.0
                        : 180.0,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF07325D),
                    ),
                  ),
                ),
              )
              : Container(
                height:
                    _isExtraSmallScreen
                        ? 140.0
                        : _isSmallScreen
                        ? 160.0
                        : 180.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: _basePadding),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final cardWidth =
                        _isExtraSmallScreen
                            ? 200.0
                            : _isSmallScreen
                            ? 220.0
                            : _isMediumScreen
                            ? 240.0
                            : _isTablet
                            ? 280.0
                            : 260.0;
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
    final cardHeight =
        _isExtraSmallScreen
            ? 140.0
            : _isSmallScreen
            ? 160.0
            : 180.0;

    return Container(
      height: cardHeight,
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
            Navigator.pushNamed(context, '/course-detail', arguments: course);
          },
          child: Padding(
            padding: EdgeInsets.all(_isExtraSmallScreen ? 10.0 : _smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width:
                          _isExtraSmallScreen
                              ? 28.0
                              : _isSmallScreen
                              ? 32.0
                              : 40.0,
                      height:
                          _isExtraSmallScreen
                              ? 28.0
                              : _isSmallScreen
                              ? 32.0
                              : 40.0,
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
                SizedBox(height: _isExtraSmallScreen ? 12.0 : _smallPadding),
                Expanded(
                  flex: 3,
                  child: Text(
                    course.title,
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                    maxLines: _isExtraSmallScreen ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: _isExtraSmallScreen ? 6.0 : _smallPadding * 0.8,
                ),
                Container(
                  width: double.infinity,
                  height:
                      _isExtraSmallScreen
                          ? 28.0
                          : _isSmallScreen
                          ? 32.0
                          : 36.0,
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
                        Icon(
                          Icons.visibility_outlined,
                          size: _isExtraSmallScreen ? 10.0 : _captionFontSize,
                        ),
                        SizedBox(width: 6),
                        FittedBox(
                          child: Text(
                            'ເບິ່ງລາຍລະອຽດ',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _captionFontSize * 0.9,
                              fontWeight: FontWeight.w600,
                            ),
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
  }

  Widget _buildCourseIcon(CourseModel course) {
    final iconSize =
        _isExtraSmallScreen
            ? 12.0
            : _isSmallScreen
            ? 14.0
            : 18.0;

    if (course.icon != null &&
        course.icon!.isNotEmpty &&
        Uri.tryParse(course.icon!) != null &&
        course.icon!.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          course.icon!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              FontAwesomeIcons.graduationCap,
              size: iconSize,
              color: Colors.white,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Icon(
              FontAwesomeIcons.graduationCap,
              size: iconSize,
              color: Colors.white,
            );
          },
        ),
      );
    }

    return Icon(
      FontAwesomeIcons.graduationCap,
      size: iconSize,
      color: Colors.white,
    );
  }

  // Enhanced News Section
  Widget _buildNewsSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _basePadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          'ຂ່າວສານລ່າສຸດ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: _titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF07325D),
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ອັບເດດຂໍ້ມູນຂ່າວສານໃໝ່ລ່າສຸດ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: _captionFontSize,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/news'),
                  child: Text(
                    'ເບິ່ງທັງຫມົດ',
                    style: GoogleFonts.notoSansLao(
                      color: Color(0xFF07325D),
                      fontWeight: FontWeight.w600,
                      fontSize: _captionFontSize,
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
                        size:
                            _isExtraSmallScreen
                                ? 40.0
                                : _isSmallScreen
                                ? 50.0
                                : 60.0,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'ບໍ່ມີຂ່າວສານໃໝ່',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.grey[600],
                          fontSize: _bodyFontSize,
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
                      margin: EdgeInsets.symmetric(horizontal: _basePadding),
                      child: _buildFeaturedNewsCard(_latestNews.first),
                    ),
                  if (_latestNews.length > 1) ...[
                    SizedBox(height: 20),
                    Container(
                      height:
                          _isExtraSmallScreen
                              ? 180.0
                              : _isSmallScreen
                              ? 200.0
                              : 220.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: _basePadding),
                        itemCount: _latestNews.length - 1,
                        itemBuilder: (context, index) {
                          final cardWidth =
                              _isExtraSmallScreen
                                  ? 200.0
                                  : _isSmallScreen
                                  ? 220.0
                                  : _isTablet
                                  ? 280.0
                                  : 250.0;
                          return Container(
                            width: cardWidth,
                            margin: EdgeInsets.only(right: 16),
                            child: _buildCompactNewsCard(
                              _latestNews[index + 1],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildFeaturedNewsCard(Topic news) {
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
          child:
              _isExtraSmallScreen || _isSmallScreen
                  ? Column(
                    children: [
                      Container(
                        height: cardHeight * 0.5,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
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
                              Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: _captionFontSize,
                                        color: Colors.grey[500],
                                      ),
                                      SizedBox(width: 4),
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF07325D),
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
                  )
                  : Row(
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
                          borderRadius: BorderRadius.only(
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF07325D,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'ຂ່າວໃໝ່',
                                        style: GoogleFonts.notoSansLao(
                                          fontSize: _captionFontSize,
                                          color: Color(0xFF07325D),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: _captionFontSize,
                                        color: Colors.grey[500],
                                      ),
                                      SizedBox(width: 4),
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
                              SizedBox(height: 12),
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
                              SizedBox(height: 8),
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
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _smallPadding,
                                      vertical: _smallPadding * 0.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF07325D),
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
                  ),
        ),
      ),
    );
  }

  Widget _buildCompactNewsCard(Topic news) {
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
                height: cardHeight * 0.4,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
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
                      SizedBox(height: 6),
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
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: _captionFontSize,
                            color: Colors.grey[400],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${news.visits}',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _captionFontSize * 0.8,
                              color: Colors.grey[400],
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: _captionFontSize,
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
              size: height != null ? height * 0.3 : 60.0,
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
        size: height != null ? height * 0.3 : 60.0,
        color: Colors.white,
      ),
    );
  }

  // Enhanced Quick Actions Section
  Widget _buildQuickActionsSection() {
    return Container(
      margin: EdgeInsets.all(_basePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ການດຳເນີນງານດ່ວນ',
            style: GoogleFonts.notoSansLao(
              fontSize: _titleFontSize,
              fontWeight: FontWeight.bold,
              color: Color(0xFF07325D),
            ),
          ),
          SizedBox(height: 16),
          _isExtraSmallScreen || _isSmallScreen
              ? Column(
                children: [
                  _buildQuickActionCard(
                    icon: Icons.phone,
                    title: 'ຕິດຕໍ່ເຮົາ',
                    subtitle: 'ສອບຖາມຂໍ້ມູນເພີ່ມເຕີມ',
                    color: Color(0xFF2E7D32),
                    onTap: () {},
                  ),
                  SizedBox(height: 12),
                  _buildQuickActionCard(
                    icon: Icons.school,
                    title: 'ສະໝັກຮຽນ',
                    subtitle: 'ລົງທະບຽນຮຽນ',
                    color: Color(0xFFE65100),
                    onTap: () {},
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.phone,
                      title: 'ຕິດຕໍ່ເຮົາ',
                      subtitle: 'ສອບຖາມຂໍ້ມູນເພີ່ມເຕີມ',
                      color: Color(0xFF2E7D32),
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.school,
                      title: 'ສະໝັກຮຽນ',
                      subtitle: 'ລົງທະບຽນຮຽນ',
                      color: Color(0xFFE65100),
                      onTap: () {},
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
            padding: EdgeInsets.all(_isExtraSmallScreen ? 10.0 : _basePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    _isExtraSmallScreen ? 6.0 : _smallPadding * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size:
                        _isExtraSmallScreen
                            ? 18.0
                            : _isSmallScreen
                            ? 20.0
                            : 24.0,
                    color: color,
                  ),
                ),
                SizedBox(height: _isExtraSmallScreen ? 6.0 : _smallPadding),
                FittedBox(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSansLao(
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansLao(
                    fontSize: _captionFontSize,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Floating Action Button
  Widget _buildFloatingActionButton() {
    final fabSize =
        _isExtraSmallScreen
            ? 48.0
            : _isSmallScreen
            ? 52.0
            : 56.0;
    final iconSize =
        _isExtraSmallScreen
            ? 20.0
            : _isSmallScreen
            ? 22.0
            : 24.0;

    return SizedBox(
      width: fabSize,
      height: fabSize,
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder:
                (context) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.all(_basePadding),
                  child: SafeArea(
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
                          leading: Icon(
                            Icons.search,
                            color: Color(0xFF07325D),
                            size: _isExtraSmallScreen ? 20.0 : 24.0,
                          ),
                          title: Text(
                            'ຄົ້ນຫາ',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _bodyFontSize,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.refresh,
                            color: Color(0xFF07325D),
                            size: _isExtraSmallScreen ? 20.0 : 24.0,
                          ),
                          title: Text(
                            'ໂຫຼດຂໍ້ມູນໃໝ່',
                            style: GoogleFonts.notoSansLao(
                              fontSize: _bodyFontSize,
                            ),
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
                ),
          );
        },
        backgroundColor: Color(0xFF07325D),
        child: Icon(Icons.add, color: Colors.white, size: iconSize),
      ),
    );
  }

  // Enhanced Loading Screen
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
              fontSize: _bodyFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
