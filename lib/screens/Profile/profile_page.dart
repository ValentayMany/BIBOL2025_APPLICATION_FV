import 'package:BIBOL/services/token/token_service.dart';
import 'package:BIBOL/widgets/common/custom_bottom_nav.dart';
import 'package:BIBOL/widgets/shared/modern_drawer_widget.dart';
import 'package:BIBOL/widgets/shared/shared_header_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 4;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;

  Map<String, dynamic>? userInfo;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAnimations();
    _loadUserProfile();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
    _slideController.forward();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLoginAndLoadProfile();
    }
  }

  void _checkLoginAndLoadProfile() async {
    setState(() => _isLoading = true);

    final user = await TokenService.getUserInfo();
    final isLoggedIn = await TokenService.isLoggedIn();

    if (mounted) {
      setState(() {
        if (user != null && user["id"] != null && isLoggedIn) {
          userInfo = user;
          _isLoggedIn = true;
        } else {
          userInfo = null;
          _isLoggedIn = false;
        }
        _isLoading = false;
      });
    }
  }

  void _loadUserProfile() async {
    final user = await TokenService.getUserInfo();
    final isLoggedIn = await TokenService.isLoggedIn();

    if (mounted) {
      setState(() {
        if (user != null && user["id"] != null && isLoggedIn) {
          userInfo = user;
          _isLoggedIn = true;
        } else {
          userInfo = null;
          _isLoggedIn = false;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);

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
        Navigator.pushReplacementNamed(context, '/about');
        break;
      case 4:
        break;
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.logout,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'ອອກຈາກລະບົບ',
                style: GoogleFonts.notoSansLao(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກລະບົບ?',
          style: GoogleFonts.notoSansLao(
            color: Colors.grey.shade600,
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ຍົກເລີກ',
              style: GoogleFonts.notoSansLao(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              await TokenService.clearAll();
              await Future.delayed(const Duration(milliseconds: 100));

              if (mounted) {
                setState(() {
                  _isLoggedIn = false;
                  userInfo = null;
                  _isLoading = false;
                });

                _animationController.reset();
                _animationController.forward();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'ອອກຈາກລະບົບສຳເລັດແລ້ວ',
                            style: GoogleFonts.notoSansLao(),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.all(16),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'ອອກຈາກລະບົບ',
              style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final result = await Navigator.pushNamed(context, '/login');
    if (result == true) {
      _checkLoginAndLoadProfile();
    }
  }

  void _handleEditProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ຟັງຊັ່ນແກ້ໄຂຂໍ້ມູນກຳລັງພັດທະນາ',
          style: GoogleFonts.notoSansLao(),
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF07325D),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFF),
      extendBodyBehindAppBar: true,
      drawer: ModernDrawerWidget(
        key: ValueKey('drawer_$_isLoggedIn'),
        isLoggedIn: _isLoggedIn,
        userInfo: userInfo,
        screenWidth: _screenWidth,
        screenHeight: _screenHeight,
        onLogoutPressed: _handleLogout,
        onLoginPressed: _handleLogin,
        currentRoute: '/profile',
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildBody(),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _isLoggedIn ? _buildProfileContent() : _buildLoginPrompt(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
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
          colors: [
            Color(0xFF06304F),
            Color(0xFF07325D),
            Color(0xFF0A4A85),
          ],
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
              // Header Row
              Row(
                children: [
                  SharedHeaderButton(
                    icon: Icons.menu_rounded,
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    screenWidth: _screenWidth,
                  ),
                  Spacer(),
                  if (_isLoggedIn)
                    SharedHeaderButton(
                      icon: Icons.edit_rounded,
                      onPressed: _handleEditProfile,
                      screenWidth: _screenWidth,
                    ),
                ],
              ),

              SizedBox(height: basePadding * 1.2),

              // Profile Avatar & Info
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
                          // Avatar with glow
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow
                              Container(
                                width: (_screenWidth < 320 ? 90 : _screenWidth < 360 ? 100 : 110),
                                height: (_screenWidth < 320 ? 90 : _screenWidth < 360 ? 100 : 110),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              // Avatar
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.9),
                                    ],
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: _screenWidth < 320 ? 40 : _screenWidth < 360 ? 45 : 50,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    _isLoggedIn ? Icons.person_rounded : Icons.person_outline_rounded,
                                    size: _screenWidth < 320 ? 40 : _screenWidth < 360 ? 45 : 50,
                                    color: const Color(0xFF07325D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          if (_isLoggedIn && userInfo != null) ...[
                            // ชื่อ-นามสกุล
                            Container(
                              constraints: BoxConstraints(maxWidth: _screenWidth * 0.85),
                              child: Text(
                                "${userInfo!['first_name'] ?? ''} ${userInfo!['last_name'] ?? ''}".trim(),
                                style: GoogleFonts.notoSansLao(
                                  fontSize: _screenWidth < 320 ? 20.0 : _screenWidth < 360 ? 22.0 : 24.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            // รหัสนักศึกษา
                            if (userInfo?['admission_no'] != null)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.25),
                                      Colors.white.withOpacity(0.15),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.badge,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      userInfo!['admission_no'].toString(),
                                      style: GoogleFonts.notoSansLao(
                                        fontSize: _screenWidth < 320 ? 13.0 : 14.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ] else ...[
                            Text(
                              'ສະຖາບັນການທະນາຄານ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: _screenWidth < 320 ? 20.0 : _screenWidth < 360 ? 22.0 : 24.0,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'ໂປຣໄຟລ໌ນັກສຶກສາ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: _screenWidth < 320 ? 12.0 : 13.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
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

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'ກຳລັງໂຫຼດ...',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0xFFF8FAFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF07325D).withOpacity(0.15),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF07325D).withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock_person_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'ກະລຸນາເຂົ້າສູ່ລະບົບ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF07325D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ເຂົ້າສູ່ລະບົບເພື່ອເຂົ້າເຖິງໂປຣໄຟລ໌\nແລະຂໍ້ມູນການສຶກສາຂອງທ່ານ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansLao(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF07325D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Color(0xFF07325D).withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_rounded, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'ເຂົ້າສູ່ລະບົບ',
                            style: GoogleFonts.notoSansLao(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: ข้อมูลส่วนตัว
            _buildSectionTitle('ຂໍ້ມູນສ່ວນຕົວ', Icons.person_outline),
            SizedBox(height: 12),
            
            _buildModernInfoCard(
              icon: Icons.person,
              iconColor: Color(0xFF6366F1),
              title: 'ຊື່-ນາມສະກຸນ',
              value: "${userInfo?['first_name'] ?? ''} ${userInfo?['last_name'] ?? ''}".trim().isNotEmpty
                  ? "${userInfo?['first_name'] ?? ''} ${userInfo?['last_name'] ?? ''}".trim()
                  : 'N/A',
            ),
            SizedBox(height: 12),
            
            _buildModernInfoCard(
              icon: Icons.badge,
              iconColor: Color(0xFF3B82F6),
              title: 'ລະຫັດນັກຮຽນ',
              value: userInfo?['admission_no']?.toString() ?? 'N/A',
            ),
            SizedBox(height: 12),
            
            _buildModernInfoCard(
              icon: Icons.email,
              iconColor: Color(0xFF10B981),
              title: 'ອີເມວ',
              value: userInfo?['email']?.toString() ?? 'N/A',
            ),
            
            if (userInfo?['roll_no'] != null) ...[
              SizedBox(height: 12),
              _buildModernInfoCard(
                icon: Icons.numbers,
                iconColor: Color(0xFFF59E0B),
                title: 'Roll No',
                value: userInfo!['roll_no'].toString(),
              ),
            ],
            
            SizedBox(height: 32),
            
            // Section: ການຈັດການບັນຊີ
            _buildSectionTitle('ການຈັດການບັນຊີ', Icons.settings_outlined),
            SizedBox(height: 12),
            
            _buildModernActionCard(
              icon: Icons.edit,
              iconGradient: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              title: 'ແກ້ໄຂຂໍ້ມູນສ່ວນຕົວ',
              subtitle: 'ອັບເດດຊື່, ອີເມວ ແລະຂໍ້ມູນອື່ນໆ',
              onTap: _handleEditProfile,
            ),
            SizedBox(height: 12),
            
            _buildModernActionCard(
              icon: Icons.lock,
              iconGradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
              title: 'ປ່ຽນລະຫັດຜ່ານ',
              subtitle: 'ອັບເດດລະຫັດຜ່ານເພື່ອຄວາມປອດໄພ',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'ຟັງຊັ່ນນີ້ກຳລັງພັດທະນາ',
                      style: GoogleFonts.notoSansLao(),
                    ),
                    backgroundColor: Colors.blue.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 32),
            
            // Section: ອື່ນໆ
            _buildSectionTitle('ອື່ນໆ', Icons.more_horiz),
            SizedBox(height: 12),
            
            _buildModernActionCard(
              icon: Icons.logout,
              iconGradient: [Color(0xFFEF4444), Color(0xFFDC2626)],
              title: 'ອອກຈາກລະບົບ',
              subtitle: 'ອອກຈາກບັນຊີຂອງທ່ານຢ່າງປອດໄພ',
              onTap: _handleLogout,
              isDanger: true,
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.notoSansLao(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
              letterSpacing: 1.2,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              margin: EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFBFF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: iconColor.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  iconColor.withOpacity(0.15),
                  iconColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF07325D),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionCard({
    required IconData icon,
    required List<Color> iconGradient,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFAFBFF)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDanger
                ? Colors.red.withOpacity(0.15)
                : Color(0xFF07325D).withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDanger ? Colors.red : Color(0xFF07325D)).withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: iconGradient,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: iconGradient.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSansLao(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDanger ? Colors.red.shade700 : Color(0xFF07325D),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSansLao(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDanger
                    ? Colors.red.withOpacity(0.08)
                    : Color(0xFF07325D).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDanger ? Colors.red.shade600 : Color(0xFF07325D),
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
