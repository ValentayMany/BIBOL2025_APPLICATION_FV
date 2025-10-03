// ignore_for_file: use_key_in_widget_constructors

import 'package:BIBOL/services/token/token_service.dart';
import 'package:BIBOL/widgets/common/custom_bottom_nav.dart';
import 'package:BIBOL/widgets/shared/modern_drawer_widget.dart';
import 'package:BIBOL/widgets/shared/shared_header_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatefulWidget {
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 3;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // เพิ่ม state สำหรับ login
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userInfo;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _checkLoginStatus();  // เพิ่มการเช็ค login
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // เพิ่ม method สำหรับเช็ค login
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
      print('Error checking login status: $e');
    }
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/news');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/gallery');
        break;
      case 3:
        // stay on current page
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  // เพิ่ม method สำหรับ logout
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
                        content: Text(
                          'ອອກຈາກລະບົບສຳເລັດ',
                          style: GoogleFonts.notoSansLao(fontSize: 14),
                        ),
                        backgroundColor: Colors.green,
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

  // เพิ่ม method สำหรับ login
  Future<void> _handleLogin() async {
    final result = await Navigator.pushNamed(context, '/login');
    if (result == true) await _checkLoginStatus();
  }

  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
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
        currentRoute: '/about',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildMainImage(),
              SizedBox(height: 8),
              _buildContentSections(),
              SizedBox(height: 100),
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

  Widget _buildHeader() {
    // Responsive values
    double basePadding = _screenWidth < 320
        ? 8.0
        : _screenWidth < 360
            ? 12.0
            : _screenWidth < 400
                ? 16.0
                : _screenWidth < 480
                    ? 18.0
                    : 20.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(basePadding * 2),
          bottomRight: Radius.circular(basePadding * 2),
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
        child: Padding(
          padding: EdgeInsets.all(basePadding),
          child: Column(
            children: [
              // Header Row with Menu Button - ใช้ SharedHeaderButton
              Row(
                children: [
                  SharedHeaderButton(
                    icon: Icons.menu_rounded,
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    screenWidth: _screenWidth,
                  ),
                  Spacer(),
                ],
              ),
              
              SizedBox(height: basePadding),
              
              // Logo and Title
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
                          _buildLogo(),
                          SizedBox(height: 20),
                          _buildTitle(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    double logoSize = _screenWidth < 320
        ? 50.0
        : _screenWidth < 360
            ? 60.0
            : _screenWidth < 400
                ? 70.0
                : _screenWidth < 480
                    ? 80.0
                    : 90.0;

    return Container(
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
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.account_balance,
              size: logoSize * 0.5,
              color: Colors.white.withOpacity(0.8),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    double titleFontSize = _screenWidth < 320
        ? 16.0
        : _screenWidth < 360
            ? 18.0
            : _screenWidth < 400
                ? 20.0
                : _screenWidth < 480
                    ? 22.0
                    : 24.0;

    return Column(
      children: [
        Text(
          'ກ່ຽວກັບ',
          style: GoogleFonts.notoSansLao(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          'ສະຖາບັນການທະນາຄານ',
          style: GoogleFonts.notoSansLao(
            fontSize: _screenWidth < 320
                ? 10.0
                : _screenWidth < 360
                    ? 11.0
                    : _screenWidth < 400
                        ? 12.0
                        : _screenWidth < 480
                            ? 13.0
                            : 14.0,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMainImage() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/image52.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ບໍ່ສາມາດໂຫຼດຮູບໄດ້',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContentSections() {
    return Column(
      children: [
        // _buildNewsSection(7),
        // _buildNewsSection(8),
        // _buildNewsSection(9),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildLoadingWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
              strokeWidth: 2,
            ),
            SizedBox(height: 12),
            Text(
              'ກໍາລັງໂຫຼດ...',
              style: GoogleFonts.notoSansLao(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildErrorWidget(String error) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'ເກີດຂໍ້ຜິດພາດ: $error',
              style: GoogleFonts.notoSansLao(
                color: Colors.red[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[700], size: 24),
          SizedBox(width: 12),
          Text(
            'ບໍ່ມີຂໍ້ມູນ',
            style: GoogleFonts.notoSansLao(
              color: Colors.amber[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    Map<String, dynamic> news,
    String content,
    List<String> people,
    bool hasPeople,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(news["title"] ?? ""),
            SizedBox(height: 16),
            _buildSectionContent(content, people, hasPeople),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07325D), Color(0xFF0A4B7A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.article_outlined, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.notoSansLao(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(
    String content,
    List<String> people,
    bool hasPeople,
  ) {
    if (hasPeople) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: people.map((p) => _buildListItem("ທ່ານ$p")).toList(),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          content,
          style: GoogleFonts.notoSansLao(
            fontSize: 15,
            color: Colors.black87,
            height: 1.6,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.justify,
        ),
      );
    }
  }

  Widget _buildListItem(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Color(0xFF07325D),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.notoSansLao(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
