import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:BIBOL/services/auth/students_auth_service.dart';
import 'package:BIBOL/services/token/token_service.dart';
import 'dart:ui';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _admissionNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _shakeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    _admissionNoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = StudentAuthService();

      debugPrint('🔐 Starting login process...');
      debugPrint('📧 Email: ${_emailController.text.trim()}');
      debugPrint('🎫 Admission No: ${_admissionNoController.text.trim()}');

      final response = await authService.login(
        admissionNo: _admissionNoController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (response != null && response.success && response.data != null) {
        debugPrint('✅ Login API successful!');

        // บันทึก Token
        if (response.token != null && response.token!.isNotEmpty) {
          await TokenService.saveToken(response.token!);
          debugPrint('✅ Token saved: ${response.token}');
        } else {
          debugPrint('⚠️ No token in response');
        }

        // บันทึกข้อมูล Student จาก login response ก่อน
        final studentData = response.data!.toJson();
        await TokenService.saveUserInfo(studentData);
        debugPrint('✅ Initial user info saved');

        // ดึงข้อมูล profile เต็มจาก /profile endpoint
        try {
          debugPrint('🔄 Fetching full profile...');
          final fullProfile = await authService.getProfile();
          if (fullProfile != null) {
            await TokenService.saveUserInfo(fullProfile);
            debugPrint('✅ Full profile saved with all fields');
          } else {
            debugPrint('⚠️ Could not fetch full profile, using login data');
          }
        } catch (e) {
          debugPrint('⚠️ Error fetching full profile: $e, using login data');
        }

        // ตรวจสอบว่าบันทึกสำเร็จไหม
        final isLoggedIn = await TokenService.isLoggedIn();
        debugPrint('🔍 Verify login status: $isLoggedIn');

        if (!mounted) return;

        if (isLoggedIn) {
          _showSuccessSnackBar();

          await Future.delayed(Duration(milliseconds: 500));

          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          throw Exception('Failed to verify login status');
        }
      } else {
        _shakeController.forward();
        _showErrorSnackBar(response?.message ?? 'ເຂົ້າສູ່ລະບົບບໍ່ສຳເລັດ');
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _shakeController.forward();
      if (mounted) {
        _showErrorSnackBar('ເກີດຂໍ້ຜິດພາດ: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text("ເຂົ້າສູ່ລະບົບສຳເລັດ!", style: GoogleFonts.notoSansLao()),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(message, style: GoogleFonts.notoSansLao())),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Color(0xFF1A237E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'ລືມລະຫັດ?',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'ກະລຸນາຕິດຕໍ່ຜູ້ດູແລລະບົບເພື່ອຣີເຊັດລະຫັດຜ່ານ.',
              style: GoogleFonts.notoSansLao(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ຕົກລົງ',
                  style: GoogleFonts.notoSansLao(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
              ),
            ),
          ),
          // Animated Background Circles
          Positioned(
            top: -100,
            left: -100,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
          // Main Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        constraints.maxWidth > 600
                            ? (constraints.maxWidth - 600) / 2
                            : 20.0,
                    vertical: 10.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 20,
                      maxWidth: 600,
                    ),
                    child: FadeTransition(
                      opacity: _animation,
                      child: AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              _shakeAnimation.value *
                                  10 *
                                  (1 - _shakeAnimation.value),
                              0,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Logo with Hero Animation
                                  Hero(
                                    tag: 'app_logo',
                                    child: Image.asset(
                                      'assets/images/LOGO.png',
                                      height: 100,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    'ສະຖາບັນການທະນາຄານ',
                                    style: GoogleFonts.notoSansLao(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ເຂົ້າສູ່ລະບົບ',
                                    style: GoogleFonts.notoSansLao(
                                      fontSize: 15,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  _buildGlassmorphicContainer(
                                    child: Column(
                                      children: [
                                        _buildAdmissionNoField(),
                                        const SizedBox(height: 16),
                                        _buildEmailField(),
                                        const SizedBox(height: 8),
                                        _buildForgotPasswordBtn(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildLoginBtn(),
                                  const SizedBox(height: 16),
                                  _buildBackBtn(),
                                  const SizedBox(height: 16),
                                  _buildVersionInfo(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: _buildGlassmorphicContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'ກຳລັງເຂົ້າສູ່ລະບົບ...',
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAdmissionNoField() {
    return TextFormField(
      controller: _admissionNoController,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'ກະລຸນາປ້ອນລະຫັດນັກຮຽນ';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'ລະຫັດນັກຮຽນ (Admission No)',
        labelStyle: GoogleFonts.notoSansLao(
          color: Colors.white70,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          FontAwesomeIcons.user,
          color: Colors.white70,
          size: 18,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: GoogleFonts.notoSansLao(
          color: Colors.red[300],
          fontSize: 11,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'ກະລຸນາປ້ອນອີເມວ';
        }
        if (!value.contains('@')) {
          return 'ອີເມວບໍ່ຖືກຕ້ອງ';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'ອີເມວ (Email)',
        labelStyle: GoogleFonts.notoSansLao(
          color: Colors.white70,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: Colors.white70,
          size: 18,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: GoogleFonts.notoSansLao(
          color: Colors.red[300],
          fontSize: 11,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _showForgotPasswordDialog,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4),
        ),
        child: Text(
          'ລືມລະຫັດ?',
          style: GoogleFonts.notoSansLao(color: Colors.white70, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.5),
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0D47A1),
                    ),
                  ),
                )
                : Text(
                  'ເຂົ້າສູ່ລະບົບ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D47A1),
                  ),
                ),
      ),
    );
  }

  Widget _buildBackBtn() {
    return TextButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 20),
      label: Text(
        'ກັບຄືນ',
        style: GoogleFonts.notoSansLao(
          color: Colors.white70,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'Version 1.0.0',
      style: GoogleFonts.notoSansLao(color: Colors.white54, fontSize: 11),
    );
  }
}
