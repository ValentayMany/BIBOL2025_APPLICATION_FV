import 'package:auth_flutter_api/services/basic_infor.dart';
import 'package:auth_flutter_api/widgets/custom_bottom_nav.dart';
import 'package:auth_flutter_api/services/token_service.dart'; // 🔹 เพิ่ม import
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

  final List<String> _carouselItems = [
    'assets/images/image52.png',
    'assets/images/LOGO.png',
    'assets/images/image52.png',
    'assets/images/LOGO.png',
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _pageController = PageController(initialPage: 0);

    // Animation controllers
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

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    _carouselTimer = Timer.periodic(Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      final next = (_carouselIndex + 1) % _carouselItems.length;
      _pageController.animateToPage(
        next,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  // 🔹 แก้ไขฟังก์ชันตรวจสอบสถานะการล็อกอิน
  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await TokenService.isLoggedIn();
    final userInfo = await TokenService.getUserInfo();

    setState(() {
      _isLoggedIn = isLoggedIn;
      _userInfo = userInfo;
    });
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
        // หน้าหลัก - อยู่ที่นี่แล้ว
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

  // 🔹 ฟังก์ชันล็อกเอาต์
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
                  Navigator.pop(context); // ปิด dialog

                  // ลบข้อมูลการล็อกอิน
                  await TokenService.clearAll();

                  // อัพเดทสถานะ
                  await _checkLoginStatus();

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

  Widget _buildNewsCard(int index) {
    return Container(
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
        children: [
          Expanded(
            flex: 3,
            child: Container(
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
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/news');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07325D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'ອ່ານເພີ່ມເຕີມ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 แสดงชื่อผู้ใช้
                  // if (_userInfo != null)
                  //   Container(
                  //     margin: EdgeInsets.only(right: 8),
                  //     padding: EdgeInsets.symmetric(
                  //       horizontal: 12,
                  //       vertical: 6,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white.withOpacity(0.1),
                  //       borderRadius: BorderRadius.circular(15),
                  //       border: Border.all(
                  //         color: Colors.white.withOpacity(0.2),
                  //       ),
                  //     ),
                  //     child: Text(
                  //       "${_userInfo!['first_name'] ?? ''} ${_userInfo!['last_name'] ?? ''}"
                  //           .trim(),
                  //       style: GoogleFonts.notoSansLao(
                  //         color: Colors.white,
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ),

                  // ปุ่มล็อกเอาต์
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
                  ),
                ],
              ),
            )
          else
            // 🔹 ปุ่มล็อกอินเมื่อยังไม่ได้ล็อกอิน
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
                    // 🔹 แสดงชื่อผู้ใช้ใน Drawer
                    if (_isLoggedIn && _userInfo != null)
                      Column(
                        children: [
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
                        ],
                      )
                    else if (!_isLoggedIn)
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
                        Navigator.pop(context); // ปิด drawer ก่อน
                        final result = await Navigator.pushNamed(context, '/');
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
      body: SingleChildScrollView(
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
                            // Enhanced indicators
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_carouselItems.length, (
                                  i,
                                ) {
                                  final active = i == _carouselIndex;
                                  return AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    width: active ? 24 : 8,
                                    height: 8,
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          active
                                              ? Colors.white
                                              : Colors.white54,
                                      borderRadius: BorderRadius.circular(4),
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
                                }),
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

                      SizedBox(height: 24),

                      // Enhanced Course Cards
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: FutureBuilder<Map<String, dynamic>>(
                                  future: InforService.getNewsById(4),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return _buildLoadingCard();
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return _buildErrorCard();
                                    }
                                    return _buildGradientCard(
                                      content: snapshot.data!["content"],
                                      gradientColors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2),
                                      ],
                                      icon: Icons.school_rounded,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: FutureBuilder<Map<String, dynamic>>(
                                  future: InforService.getNewsById(5),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return _buildLoadingCard();
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return _buildErrorCard();
                                    }
                                    return _buildGradientCard(
                                      content: snapshot.data!["content"],
                                      gradientColors: [
                                        Color(0xFFf093fb),
                                        Color(0xFFf5576c),
                                      ],
                                      icon: Icons.psychology_rounded,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          FutureBuilder<Map<String, dynamic>>(
                            future: InforService.getNewsById(6),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildLoadingCard();
                              } else if (snapshot.hasError ||
                                  !snapshot.hasData) {
                                return _buildErrorCard();
                              }
                              return _buildGradientCard(
                                content: snapshot.data!["content"],
                                gradientColors: [
                                  Color(0xFF4facfe),
                                  Color(0xFF00f2fe),
                                ],
                                icon: Icons.business_center_rounded,
                              );
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 32),

                      // News Section
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'ຂ່າວຫຼ້າສຸດ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF07325D),
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 3,
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

                      SizedBox(height: 20),

                      // Enhanced News Grid
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) => _buildNewsCard(index),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  // 🔹 แก้ไขฟังก์ชัน _buildDrawerItem เพื่อรองรับสถานะล็อกเอาต์
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
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isLogout
                    ? Colors.red.withOpacity(0.1)
                    : Color(0xFF07325D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isLogout ? Colors.red : Color(0xFF07325D)),
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSansLao(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: isLogout ? Colors.red : null,
          ),
        ),
        onTap:
            onTap ??
            () {
              if (route != null) {
                Navigator.pushReplacementNamed(context, route);
              }
            },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07325D)),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[600]),
            SizedBox(height: 8),
            Text(
              'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້',
              style: GoogleFonts.notoSansLao(
                color: Colors.red[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
