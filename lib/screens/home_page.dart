// pages/Home_page.dart
import 'package:BIBOL/models/course_model.dart' show CourseModel;
import 'package:BIBOL/services/Course_service.dart' show CourseService;
import 'package:BIBOL/widgets/custom_bottom_nav.dart';
import 'package:BIBOL/services/token_service.dart';
import 'package:BIBOL/widgets/banner_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

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

  // 👉 state สำหรับ courses
  List<CourseModel> _courses = [];
  bool _isCoursesLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _fetchCourses(); // โหลดคอร์สด้วย
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

  // 👉 โหลดคอร์สจาก API
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
              : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [_buildHeaderSection(), _buildContentSection()],
                ),
              ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  // 👉 Drawer UI
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

  // 👉 Loading UI
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
          ),
          SizedBox(height: 20),
          Text(
            'ກຳລັງໂຫຼດ...',
            style: GoogleFonts.notoSansLao(
              color: Color(0xFF07325D),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 👉 Header Section
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
              height: 280,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const BannerSliderWidget(
                height: 280,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 4),
                showIndicators: true,
                showNavigationButtons: false,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                margin: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // 👉 Content Section (Courses)
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
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          colors: [Color(0xFF07325D), Color(0xFF0A4A73)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              // 👉 Courses List
              if (_isCoursesLoading) ...[
                Center(
                  child: CircularProgressIndicator(color: Color(0xFF07325D)),
                ),
              ] else if (_errorMessage != null) ...[
                Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ] else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading:
                            course.icon != null
                                ? Image.network(
                                  course.icon!,
                                  width: 40,
                                  height: 40,
                                  errorBuilder:
                                      (_, __, ___) => Icon(
                                        Icons.book,
                                        color: Color(0xFF07325D),
                                      ),
                                )
                                : Icon(Icons.book, color: Color(0xFF07325D)),
                        title: Text(
                          course.title,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF07325D),
                          ),
                        ),
                        subtitle: Text(
                          course.details,
                          style: GoogleFonts.notoSansLao(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        onTap: () {
                          // 👉 Action เมื่อกดคอร์ส (ไปหน้า detail)
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
