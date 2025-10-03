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

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
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
      builder:
          (context) => AlertDialog(
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
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
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
      extendBodyBehindAppBar: true,  // ← เพิ่มบรรทัดนี้
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
    // Responsive values (เหมือนกับ HeaderWidget และ NewsSearchHeaderWidget)
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
          begin: Alignment.topLeft,         // ← เปลี่ยนจาก topCenter
          end: Alignment.bottomRight,        // ← เปลี่ยนจาก bottomCenter
          colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(basePadding * 2),   // ← ใช้ basePadding
          bottomRight: Radius.circular(basePadding * 2),  // ← ใช้ basePadding
        ),
        boxShadow: [                                       // ← เพิ่ม boxShadow
          BoxShadow(
            color: Color(0xFF07325D).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(basePadding),           // ← เปลี่ยน padding
          child: Column(
            children: [
              // Header Row - ใช้โครงสร้างเดียวกับ HeaderWidget
              Row(
                children: [
                  SharedHeaderButton(
                    icon: Icons.menu_rounded,
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    screenWidth: _screenWidth,
                  ),
                  Spacer(),                                 // ← ใช้ Spacer
                  if (_isLoggedIn)
                    SharedHeaderButton(
                      icon: Icons.edit_rounded,
                      onPressed: _handleEditProfile,
                      screenWidth: _screenWidth,
                    ),
                ],
              ),

              SizedBox(height: basePadding),               // ← ใช้ basePadding

              // Profile Avatar & Info - เพิ่ม TweenAnimationBuilder
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: _screenWidth < 320
                                  ? 40
                                  : _screenWidth < 360
                                      ? 45
                                      : 50,
                              backgroundColor: Colors.white,
                              child: Icon(
                                _isLoggedIn
                                    ? Icons.person_rounded
                                    : Icons.person_outline_rounded,
                                size: _screenWidth < 320
                                    ? 40
                                    : _screenWidth < 360
                                        ? 45
                                        : 50,
                                color: const Color(0xFF07325D),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_isLoggedIn && userInfo != null) ...[
                            // ชื่อ-นามสกุล ← เพิ่มส่วนนี้
                            Container(
                              constraints:
                                  BoxConstraints(maxWidth: _screenWidth * 0.85),
                              child: Text(
                                "${userInfo!['first_name'] ?? ''} ${userInfo!['last_name'] ?? ''}"
                                    .trim(),
                                style: GoogleFonts.notoSansLao(
                                  fontSize: _screenWidth < 320
                                      ? 18.0
                                      : _screenWidth < 360
                                          ? 20.0
                                          : _screenWidth < 400
                                              ? 22.0
                                              : 24.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // รหัสนักศึกษา
                            if (userInfo?['admission_no'] != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('🎓', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 6),
                                    Text(
                                      userInfo!['admission_no'].toString(),
                                      style: GoogleFonts.notoSansLao(
                                        fontSize: _screenWidth < 320
                                            ? 11.0
                                            : _screenWidth < 360
                                                ? 12.0
                                                : 13.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
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
                                fontSize: _screenWidth < 320
                                    ? 18.0
                                    : _screenWidth < 360
                                        ? 20.0
                                        : _screenWidth < 400
                                            ? 22.0
                                            : 24.0,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'ໂປຣໄຟລ໌ນັກສຶກສາ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: _screenWidth < 320
                                    ? 10.0
                                    : _screenWidth < 360
                                        ? 11.0
                                        : _screenWidth < 400
                                            ? 12.0
                                            : 13.0,
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
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF07325D), Color(0xFF0A4A85)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ກະລຸນາເຂົ້າສູ່ລະບົບ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF07325D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ເຂົ້າສູ່ລະບົບເພື່ອເຂົ້າເຖິງໂປຣໄຟລ໌ຂອງທ່ານ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansLao(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogin,
                      icon: Icon(Icons.login_rounded, size: 22),
                      label: Text(
                        'ເຂົ້າສູ່ລະບົບ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF07325D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ชื่อ-นามสกุล Card ← เพิ่มส่วนนี้
            _buildInfoCard(
              icon: Icons.person_rounded,
              iconColor: Colors.purple,
              title: 'ຊື່-ນາມສະກຸນ',
              value:
                  "${userInfo?['first_name'] ?? ''} ${userInfo?['last_name'] ?? ''}"
                      .trim()
                      .isNotEmpty
                      ? "${userInfo?['first_name'] ?? ''} ${userInfo?['last_name'] ?? ''}"
                          .trim()
                      : 'N/A',
            ),
            SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.badge_rounded,
              iconColor: Colors.blue,
              title: 'ລະຫັດນັກຮຽນ',
              value: userInfo?['admission_no']?.toString() ?? 'N/A',
            ),
            SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.email_rounded,
              iconColor: Colors.green,
              title: 'ອີເມວ',
              value: userInfo?['email']?.toString() ?? 'N/A',
            ),
            if (userInfo?['roll_no'] != null) ...[
              SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.numbers_rounded,
                iconColor: Colors.orange,
                title: 'Roll No',
                value: userInfo!['roll_no'].toString(),
              ),
            ],
            SizedBox(height: 24),
            _buildActionCard(
              icon: Icons.edit_rounded,
              iconColor: Colors.blue,
              title: 'ແກ້ໄຂຂໍ້ມູນສ່ວນຕົວ',
              subtitle: 'ອັບເດດຂໍ້ມູນຂອງທ່ານ',
              onTap: _handleEditProfile,
            ),
            SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.lock_rounded,
              iconColor: Colors.orange,
              title: 'ປ່ຽນລະຫັດຜ່ານ',
              subtitle: 'ອັບເດດລະຫັດຜ່ານຂອງທ່ານ',
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
            SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.logout_rounded,
              iconColor: Colors.red,
              title: 'ອອກຈາກລະບົບ',
              subtitle: 'ອອກຈາກບັນຊີຂອງທ່ານ',
              onTap: _handleLogout,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF07325D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
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
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF07325D),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSansLao(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
