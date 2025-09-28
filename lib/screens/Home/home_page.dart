// pages/Home_page.dart - Fixed with proper imports and corrections
import 'package:BIBOL/models/course/course_model.dart' show CourseModel;
import 'package:BIBOL/models/news/news_response.dart' show NewsResponse;
import 'package:BIBOL/models/topic/topic_model.dart' show Topic;
import 'package:BIBOL/screens/News/news_detail_in_home.dart';
import 'package:BIBOL/screens/all_widgets/home_widgets/course_card_widget.dart';
import 'package:BIBOL/screens/all_widgets/home_widgets/header_widget.dart';
import 'package:BIBOL/screens/all_widgets/home_widgets/modern_drawer_widget.dart';
import 'package:BIBOL/screens/all_widgets/home_widgets/news_card_widget.dart';
import 'package:BIBOL/screens/all_widgets/home_widgets/quick_action_widget.dart';
import 'package:BIBOL/screens/all_widgets/home_widgets/search_widget.dart';
import 'package:BIBOL/screens/all_widgets/home_widgets/section_header_widget.dart';
import 'package:BIBOL/services/course/course_Service.dart';
import 'package:BIBOL/services/news/news_service.dart' show NewsService;
import 'package:BIBOL/widgets/custom_bottom_nav.dart';
import 'package:BIBOL/services/token/token_service.dart';
import 'package:BIBOL/widgets/banner/banner_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../services/auth/auth_service.dart';
import 'package:BIBOL/screens/all_widgets/home_widgets/improved_stats_card_widget.dart';

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

  // State for courses
  List<CourseModel> _courses = [];
  bool _isCoursesLoading = true;
  String? _errorMessage;

  // State for news
  List<Topic> _latestNews = [];
  bool _isNewsLoading = true;
  String? _newsErrorMessage;

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // GlobalKey for scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      await Future.delayed(const Duration(milliseconds: 300));

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

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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

  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;
  bool get _isExtraSmallScreen => _screenWidth < 320;
  bool get _isSmallScreen => _screenWidth < 375;

  double get _basePadding {
    if (_isExtraSmallScreen) return 10.0;
    if (_isSmallScreen) return 12.0;
    return 16.0;
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF07325D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'ອອກຈາກລະບົບ',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Text(
              'ທ່ານຕ້ອງການອອກຈາກລະບົບບໍ່?',
              style: GoogleFonts.notoSansLao(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ຍົກເລີກ',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.white70,
                    fontSize: 12,
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
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'ອອກຈາກລະບົບສຳເລັດ',
                                style: GoogleFonts.notoSansLao(fontSize: 12),
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
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handleLogin() async {
    final result = await Navigator.pushNamed(context, '/login');
    if (result == true) {
      await _checkLoginStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF07325D),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFF),
      drawer: ModernDrawerWidget(
        isLoggedIn: _isLoggedIn,
        userInfo: _userInfo,
        screenWidth: _screenWidth,
        screenHeight: _screenHeight,
        onLogoutPressed: _handleLogout,
        onLoginPressed: _handleLogin,
      ),
      extendBodyBehindAppBar: true,
      body:
          _isLoading
              ? _buildLoadingScreen()
              : SafeArea(
                top: false,
                child: Container(
                  color: const Color(0xFFF8FAFF),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: HeaderWidget(
                          onMenuPressed:
                              () => _scaffoldKey.currentState?.openDrawer(),
                          onLogoutPressed: _isLoggedIn ? _handleLogout : null,
                          onLoginPressed: !_isLoggedIn ? _handleLogin : null,
                          isLoggedIn: _isLoggedIn,
                          userInfo: _userInfo,
                          screenWidth: _screenWidth,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SearchWidget(
                              controller: _searchController,
                              onChanged: (value) => setState(() {}),
                              screenWidth: _screenWidth,
                            ),
                            ImprovedStatsCardWidget(
                              coursesCount: _courses.length,
                              newsCount: _latestNews.length,
                            ),
                            _buildCoursesSection(),
                            _buildNewsSection(),
                            QuickActionWidget(screenWidth: _screenWidth),
                            const SizedBox(height: 100),
                          ],
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
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCoursesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderWidget(
            title: 'ຫຼັກສູດການສຶກສາ',
            subtitle: 'ເລືອກຫຼັກສູດທີ່ເໝາະກັບທ່ານ',
            screenWidth: _screenWidth,
            onActionPressed: () {},
          ),
          const SizedBox(height: 16),
          _isCoursesLoading
              ? Container(
                height:
                    _isExtraSmallScreen
                        ? 140.0
                        : _isSmallScreen
                        ? 160.0
                        : 180.0,
                child: const Center(
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
                            : 260.0;
                    return Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(right: 16),
                      child: CourseCardWidget(
                        course: _courses[index],
                        screenWidth: _screenWidth,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/course-detail',
                            arguments: _courses[index],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderWidget(
            title: 'ຂ່າວສານລ່າສຸດ',
            subtitle: 'ອັບເດດຂໍ້ມູນຂ່າວສານໃໝ່ລ່າສຸດ',
            screenWidth: _screenWidth,
            onActionPressed: () => Navigator.pushNamed(context, '/news'),
          ),
          const SizedBox(height: 20),
          _isNewsLoading
              ? Container(
                height: 200,
                child: const Center(
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
                        size: _isExtraSmallScreen ? 40.0 : 60.0,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ບໍ່ມີຂ່າວສານໃໝ່',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.grey[600],
                          fontSize: 14,
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
                      child: NewsCardWidget(
                        news: _latestNews.first,
                        screenWidth: _screenWidth,
                        isFeatured: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => NewsDetailPage(
                                    newsId: _latestNews.first.id.toString(),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (_latestNews.length > 1) ...[
                    const SizedBox(height: 20),
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
                          final cardWidth = _isExtraSmallScreen ? 200.0 : 250.0;
                          return Container(
                            width: cardWidth,
                            margin: const EdgeInsets.only(right: 16),
                            child: NewsCardWidget(
                              news: _latestNews[index + 1],
                              screenWidth: _screenWidth,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => NewsDetailPage(
                                          newsId:
                                              _latestNews[index + 1].id
                                                  .toString(),
                                        ),
                                  ),
                                );
                              },
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
                  decoration: const BoxDecoration(
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
                        const SizedBox(height: 20),
                        ListTile(
                          leading: Icon(
                            Icons.search,
                            color: const Color(0xFF07325D),
                            size: _isExtraSmallScreen ? 20.0 : 24.0,
                          ),
                          title: Text(
                            'ຄົ້ນຫາ',
                            style: GoogleFonts.notoSansLao(fontSize: 14),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.refresh,
                            color: const Color(0xFF07325D),
                            size: _isExtraSmallScreen ? 20.0 : 24.0,
                          ),
                          title: Text(
                            'ໂຫຼດຂໍ້ມູນໃໝ່',
                            style: GoogleFonts.notoSansLao(fontSize: 14),
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
        backgroundColor: const Color(0xFF07325D),
        child: Icon(Icons.add, color: Colors.white, size: iconSize),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'ກຳລັງໂຫຼດ...',
            style: GoogleFonts.notoSansLao(
              color: const Color(0xFF07325D),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
