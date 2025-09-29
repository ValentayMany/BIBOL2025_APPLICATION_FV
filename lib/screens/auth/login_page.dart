import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth/auth_service.dart';
import '../../services/token/token_service.dart';
import 'dart:ui';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String message = "";
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      message = "";
    });

    try {
      final res = await AuthService.loginStudent(
        studentId: codeController.text.trim(),
        password: passwordController.text,
      );

      final success = res["success"] == true;
      final token = res["data"]?["token"];
      final user = res["data"]?["student"];

      setState(() {
        _isLoading = false;
        message = res["message"] ?? "";
      });

      if (success && token != null) {
        print("✅ Login Success: $token");
        print("👤 User Data: $user");

        await TokenService.saveToken(token);
        if (user != null) {
          await TokenService.saveUserInfo(user);
        }

        _showSuccessSnackBar();

        await Future.delayed(const Duration(milliseconds: 500));

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        print("❌ Login Failed: $res");
        _shakeController.forward();
        _showErrorSnackBar();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        message = "Connection error. Please try again.";
      });
      _shakeController.forward();
      _showErrorSnackBar();
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'ອອກຈາກລະບົບ',
              style: GoogleFonts.notoSansLao(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'ທ່ານຕ້ອງການອອກຈາກລະບົບບໍ່?',
              style: GoogleFonts.notoSansLao(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ຍົກເລີກ', style: GoogleFonts.notoSansLao()),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await TokenService.clearToken();
                  await TokenService.clearUserInfo();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ອອກຈາກລະບົບສຳເລັດ'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
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

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text("ເຂົ້າສູ່ລະບົບສຳເລັດ!"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message.isNotEmpty
                    ? message
                    : "ເຂົ້າສູ່ລະບົບລົ້ມເຫຼວ. ກະລຸນາກວດສອບຂໍ້ມູນການເຂົ້າສູ່ລະບົບ.",
              ),
            ),
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
    codeController.dispose();
    passwordController.dispose();
    super.dispose();
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
          // Main Content - ปรับปรุง layout และ spacing
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        constraints.maxWidth > 600
                            ? (constraints.maxWidth - 600) / 2
                            : 20.0, // ลดจาก 32 เหลือ 20
                    vertical: 10.0, // ลดจาก default
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
                                  // Logo with Hero Animation - ลดขนาด
                                  Hero(
                                    tag: 'app_logo',
                                    child: Image.asset(
                                      'assets/images/LOGO.png',
                                      height: 100, // ลดจาก 120 เหลือ 100
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ), // ลดจาก 40 เหลือ 30
                                  Text(
                                    'ສະຖາບັນການທະນາຄານ',
                                    style: GoogleFonts.notoSansLao(
                                      fontSize: 26, // ลดจาก 28 เหลือ 26
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8), // ลดจาก 10 เหลือ 8
                                  Text(
                                    'ເຂົ້າສູ່ລະບົບ',
                                    style: GoogleFonts.notoSansLao(
                                      fontSize: 15, // ลดจาก 16 เหลือ 15
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ), // ลดจาก 40 เหลือ 30
                                  _buildGlassmorphicContainer(
                                    child: Column(
                                      children: [
                                        _buildCodeTF(),
                                        const SizedBox(
                                          height: 16,
                                        ), // ลดจาก 20 เหลือ 16
                                        _buildPasswordTF(),
                                        const SizedBox(
                                          height: 8,
                                        ), // ลดจาก 10 เหลือ 8
                                        _buildForgotPasswordBtn(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ), // ลดจาก 30 เหลือ 24
                                  _buildLoginBtn(),
                                  const SizedBox(
                                    height: 16,
                                  ), // ลดจาก 20 เหลือ 16
                                  _buildSignupBtn(),
                                  const SizedBox(
                                    height: 16,
                                  ), // ลดจาก 20 เหลือ 16
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
          padding: const EdgeInsets.all(18), // ลดจาก 20 เหลือ 18
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

  Widget _buildCodeTF() {
    return TextFormField(
      controller: codeController,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'ປ້ອນລະຫັດນັກສຶກສາ';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'ລະຫັດນັກສຶກສາ',
        labelStyle: GoogleFonts.notoSansLao(
          color: Colors.white70,
          fontSize: 13, // ลดขนาดฟอนต์
        ),
        prefixIcon: const Icon(
          FontAwesomeIcons.user,
          color: Colors.white70,
          size: 18, // ลดขนาด icon
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
          fontSize: 11, // ลดขนาดฟอนต์ error
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, // ลดจาก 16
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildPasswordTF() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => login(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'ປ້ອນລະຫັດຜ່ານ';
        }
        if (value.length < 6) {
          return 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'ລະຫັດຜ່ານ',
        labelStyle: GoogleFonts.notoSansLao(
          color: Colors.white70,
          fontSize: 13, // ลดขนาดฟอนต์
        ),
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.white70,
          size: 18, // ลดขนาด icon
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
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
          fontSize: 11, // ลดขนาดฟอนต์ error
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, // ลดจาก 16
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
          padding: const EdgeInsets.symmetric(vertical: 4), // ลด padding
        ),
        child: Text(
          'ລືມລະຫັດ?',
          style: GoogleFonts.notoSansLao(
            color: Colors.white70,
            fontSize: 13, // ลดจาก 14 เหลือ 13
          ),
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return SizedBox(
      width: double.infinity,
      height: 48, // ลดจาก 50 เหลือ 48
      child: ElevatedButton(
        onPressed: _isLoading ? null : login,
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
                    fontSize: 17, // ลดจาก 18 เหลือ 17
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D47A1),
                  ),
                ),
      ),
    );
  }

  Widget _buildSignupBtn() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, "/register"),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8), // ลด padding
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'ບໍ່ມີບັນຊີ? ',
              style: GoogleFonts.notoSansLao(
                color: Colors.white70,
                fontSize: 15, // ลดจาก 16 เหลือ 15
              ),
            ),
            TextSpan(
              text: 'ລົງທະບຽນ',
              style: GoogleFonts.notoSansLao(
                color: Colors.white,
                fontSize: 15, // ลดจาก 16 เหลือ 15
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'Version 1.0.0',
      style: GoogleFonts.notoSansLao(
        color: Colors.white54,
        fontSize: 11, // ลดจาก 12 เหลือ 11
      ),
    );
  }
}
