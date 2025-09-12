import 'dart:convert';
import 'package:auth_flutter_api/config/api_config.dart';
import 'package:auth_flutter_api/services/token_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 4;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic>? userInfo;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _loadUserProfile();
  }

  void _checkLoginAndLoadProfile() async {
    final user = await TokenService.getUserInfo();
    if (user != null && user["id"] != null) {
      _fetchUserProfile(user["id"]);
    } else {
      setState(() {
        _isLoggedIn = false;
        userInfo = null;
      });
    }
  }

  void _loadUserProfile() async {
    final user = await TokenService.getUserInfo();
    if (user != null && user["id"] != null) {
      _fetchUserProfile(user["id"]);
    }
  }

  Future<void> _fetchUserProfile(int id) async {
    try {
      final token = await TokenService.getToken();

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/profile/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userInfo = data['data'];
          _isLoggedIn = true;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          userInfo = null;
        });
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        Navigator.pushReplacementNamed(context, '/about');
        break;
      case 4:
        break;
    }
  }

  // 🔹 ปรับปรุงฟังก์ชันล็อกเอาต์
  void _handleLogout() {
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
                fontWeight: FontWeight.bold,
                color: Colors.white,
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

                  // 🔹 ใช้ TokenService.clearAll() เพื่อลบข้อมูลทั้งหมด
                  await TokenService.clearAll();

                  // ไปหน้าล็อกอินและลบ route stack ทั้งหมด
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );

                  // แสดงข้อความสำเร็จ
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07325D), Color(0xFF0A4B78), Color(0xFF0D5F94)],
          ),
        ),
        child: SafeArea(
          child: _isLoggedIn ? _buildProfileContent() : _buildLoginPrompt(),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  // 🔹 เพิ่มหน้าแจ้งเตือนให้ล็อกอินก่อน
  Widget _buildLoginPrompt() {
    return Center(
      child: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'ເຂົ້າສູ່ລະບົບກ່ອນ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'ທ່ານຕ້ອງເຂົ້າສູ່ລະບົບກ່ອນຈຶ່ງຈະສາມາດເຂົ້າເບິ່ງໂປຣໄຟລໄດ້',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansLao(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Login Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/login',
                        );
                        if (result == true) {
                          _checkLoginAndLoadProfile();
                        }
                      },
                      icon: Icon(Icons.login, color: Color(0xFF07325D)),
                      label: Text(
                        'ເຂົ້າສູ່ລະບົບ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF07325D),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF07325D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Back to Home Button
                  Container(
                    width: double.infinity,
                    height: 48,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: Icon(Icons.home, color: Colors.white70, size: 20),
                      label: Text(
                        'ກັບໄປໜ້າຫຼັກ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
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

  // 🔹 เพิ่มฟังก์ชันแยกสำหรับเนื้อหาโปรไฟล์
  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildCustomAppBar(),
              _buildProfileHeader(),
              const SizedBox(height: 30),
              _buildProfileStats(),
              const SizedBox(height: 30),
              _buildProfileMenu(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ໂປຣໄຟລ',
            style: GoogleFonts.notoSansLao(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () {
                // Settings
              },
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white24, Colors.white10]),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),

          // ชื่อ-นามสกุล
          Text(
            "${userInfo?['first_name'] ?? ''} ${userInfo?['last_name'] ?? ''}",
            style: GoogleFonts.notoSansLao(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // รหัสนักศึกษา
          if (userInfo?['student_id'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'ລະຫັດນັກສຶກສາ: ${userInfo!['student_id']}',
                style: GoogleFonts.notoSansLao(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // เบอร์โทร
          if (userInfo?['phone'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'ເບີໂທ: ${userInfo!['phone']}',
                style: GoogleFonts.notoSansLao(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.school_outlined,
              title: 'ປີການສຶກສາ',
              value: '2024',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildStatCard(
              icon: Icons.class_outlined,
              title: 'ຊັ້ນຮຽນ',
              value: userInfo?['class'] ?? 'ບໍ່ລະບຸ',
              color: Colors.green,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.notoSansLao(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.notoSansLao(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.logout,
            title: 'ອອກຈາກລະບົບ',
            subtitle: 'ອອກຈາກບັນຊີຂອງທ່ານ',
            onTap: _handleLogout,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.blue),
        title: Text(
          title,
          style: GoogleFonts.notoSansLao(
            color: isLogout ? Colors.red : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.notoSansLao(color: Colors.white70),
        ),
      ),
    );
  }
}
