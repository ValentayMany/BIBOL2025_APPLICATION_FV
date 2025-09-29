import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth/auth_service.dart';
import 'dart:ui';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final lastnameController = TextEditingController();
  final numberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String message = "";
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  void register() async {
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward();
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _shakeController.forward();
      _showErrorSnackBar("ລະຫັຜ່ານບໍ່ກົງກັນ");
      return;
    }

    setState(() {
      _isLoading = true;
      message = "";
    });

    try {
      final res = await AuthService.registerStudent(
        studentId: codeController.text.trim(),
        firstName: nameController.text.trim(),
        lastName: lastnameController.text.trim(),
        phone: numberController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      print("📦 Register API Response: $res");

      final status = res["status"] == true;
      final apiMessage = res["message"]?.toString() ?? "";
      final messageLower = apiMessage.toLowerCase();

      final isSuccess =
          status ||
          messageLower.contains("success") ||
          messageLower.contains("สมัครสมาชิก") ||
          messageLower.contains("ลงทะเบียน") ||
          messageLower.contains("สำเร็จ");

      setState(() {
        _isLoading = false;
        message = apiMessage;
      });

      if (isSuccess) {
        _showSuccessDialog();
      } else {
        _shakeController.forward();
        _showErrorSnackBar(
          apiMessage.isNotEmpty ? apiMessage : "ລົງທະບຽນບໍ່ສໍາເລັດ",
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        message = "ການເຊື່ອມຕໍ່ ຜິດພາດ. ກະລຸນາລອງໃຫ່ມ.";
      });
      _shakeController.forward();
      _showErrorSnackBar(message);
      print("❌ Register Exception: $e");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF4CAF50),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'ລົງທະບຽນສຳເລັດ!',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'ບັນຊີຂອງເຈົ້າລົງທະບຽນສຳເລັດ. ເຈົ້າສາມາດລັອກອິນຕາມຂໍ້ມູນ',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'ລັອກອີນ',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4CAF50),
                      ),
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

  void _showErrorSnackBar([String? customMessage]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                customMessage ??
                    (message.isNotEmpty
                        ? message
                        : "ລົງທະບຽນບໍສຳເລັດ ກະລຸນາກວດສອບຂໍ້ມູນ."),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A237E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Terms & Conditions',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Text(
                'ໂດຍການສ້າງບັນຊີ, ທ່ານຕົກລົງເຫັນດີກັບເງື່ອນໄຂການໃຫ້ບໍລິການແລະນະໂຍບາຍຄວາມເປັນສ່ວນຕົວຂອງພວກເຮົາ. ກະລຸນາອ່ານພວກມັນຢ່າງລະອຽດກ່ອນທີ່ຈະດໍາເນີນການລົງທະບຽນ.',
                style: GoogleFonts.montserrat(color: Colors.white70),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ປີດ',
                  style: GoogleFonts.montserrat(
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
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
    nameController.dispose();
    lastnameController.dispose();
    numberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
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
                            : 20.0,
                    vertical: 10.0, // ลดจาก 16 เหลือ 10
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight - 20, // ลดจาก 32 เหลือ 20
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo - ลดขนาดและ spacing
                                Hero(
                                  tag: 'app_logo',
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxHeight: 80, // ลดจาก 100 เหลือ 80
                                      maxWidth: 80,
                                    ),
                                    child: Image.asset(
                                      'assets/images/LOGO.png',
                                      height: 80,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20), // ลดจาก 30 เหลือ 20
                                // Title
                                Text(
                                  'ສ້າງບັນຊີ',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 26, // ลดจาก 28 เหลือ 26
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8), // ลดจาก 10 เหลือ 8
                                // Subtitle
                                Text(
                                  'ເຂົ້າຮ່ວມຊຸມຊົນທະນາຄານຂອງພວກເຮົາ.',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15, // ลดจาก 16 เหลือ 15
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20), // ลดจาก 30 เหลือ 20
                                // Form Container
                                _buildGlassmorphicContainer(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        _buildCodeTF(),
                                        const SizedBox(
                                          height: 12,
                                        ), // ลดจาก 16 เหลือ 12
                                        // Name Row with flexible layout
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            if (constraints.maxWidth > 400) {
                                              return Row(
                                                children: [
                                                  Expanded(
                                                    child: _buildNameTF(),
                                                  ),
                                                  const SizedBox(
                                                    width: 12,
                                                  ), // ลดจาก 16 เหลือ 12
                                                  Expanded(
                                                    child: _buildLastnameTF(),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Column(
                                                children: [
                                                  _buildNameTF(),
                                                  const SizedBox(height: 12),
                                                  _buildLastnameTF(),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 12),

                                        _buildNumberTF(),
                                        const SizedBox(height: 12),

                                        _buildPasswordTF(),
                                        const SizedBox(
                                          height: 12,
                                        ), // ลดจาก 16 เหลือ 12
                                        _buildConfirmPasswordTF(),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16), // ลดจาก 20 เหลือ 16
                                _buildTermsCheckbox(),
                                const SizedBox(height: 16), // ลดจาก 20 เหลือ 16
                                _buildRegisterBtn(),
                                const SizedBox(height: 16), // ลดจาก 20 เหลือ 16
                                _buildLoginBtn(),
                                const SizedBox(
                                  height: 10,
                                ), // เพิ่ม spacing ล่างเล็กน้อย
                              ],
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
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ກຳລັງສ້າງບັນຊີ...',
                        style: GoogleFonts.montserrat(
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
          width: double.infinity,
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
          return 'ກະລຸນາປ້ອນລະຫັດນັກາສືກສາ';
        }
        return null;
      },
      decoration: _buildInputDecoration(
        labelText: 'ລະຫັດນັກາສືກສາ',
        prefixIcon: FontAwesomeIcons.idBadge,
      ),
    );
  }

  Widget _buildNameTF() {
    return TextFormField(
      controller: nameController,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'ຕ້ອງການ';
        }
        return null;
      },
      decoration: _buildInputDecoration(
        labelText: 'ຊື່',
        prefixIcon: FontAwesomeIcons.user,
      ),
    );
  }

  Widget _buildLastnameTF() {
    return TextFormField(
      controller: lastnameController,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'ຕ້ອງການ';
        }
        return null;
      },
      decoration: _buildInputDecoration(
        labelText: 'ນາມສະກຸນ',
        prefixIcon: FontAwesomeIcons.user,
      ),
    );
  }

  Widget _buildNumberTF() {
    return TextFormField(
      controller: numberController,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'ກະລຸນາປ້ອນເບີໂທລະສັບ';
        }
        if (value.length < 8) {
          return 'ເບີໂທລະສັບຕ້ອງມີຢ່າງໜ້ອຍ 8 ຕົວເລກ';
        }
        return null;
      },
      decoration: _buildInputDecoration(
        labelText: 'ເບີໂທລະສັບ',
        prefixIcon: FontAwesomeIcons.phone,
      ),
    );
  }

  Widget _buildPasswordTF() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'ກະລຸນາປ້ອນລະຫັດຜ່ານ';
        }
        if (value.length < 6) {
          return 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ';
        }
        return null;
      },
      decoration: _buildInputDecoration(
        labelText: 'ລະຫັດຜ່ານ',
        prefixIcon: Icons.lock,
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
      ),
    );
  }

  Widget _buildConfirmPasswordTF() {
    return TextFormField(
      controller: confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => register(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      decoration: _buildInputDecoration(
        labelText: 'ຢືນຢັນລະຫັດຜ່ານ',
        prefixIcon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
    );
  }

  // ปรับปรุง input decoration ให้กระชับมากขึ้น
  InputDecoration _buildInputDecoration({
    required String labelText,
    required dynamic prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.montserrat(
        color: Colors.white70,
        fontSize: 13,
      ), // ลดจาก 14 เหลือ 13
      prefixIcon: Icon(
        prefixIcon,
        color: Colors.white70,
        size: 18,
      ), // ลดจาก 20 เหลือ 18
      suffixIcon: suffixIcon,
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
      errorStyle: GoogleFonts.montserrat(
        color: Colors.red[300],
        fontSize: 11,
      ), // ลดจาก 12 เหลือ 11
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ), // ลดจาก 16 เหลือ 14
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: _showTermsDialog,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
        ), // ลดจาก 16 เหลือ 12
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              'ໂດຍການລົງທະບຽນ, ທ່ານຕົກລົງເຫັນດີກັບພວກເຮົາ ',
              style: GoogleFonts.montserrat(
                color: Colors.white70,
                fontSize: 11, // ลดจาก 12 เหลือ 11
              ),
            ),
            Text(
              'ຂໍ້ກຳນົດ ແລະເງື່ອນໄຂ',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 11, // ลดจาก 12 เหลือ 11
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterBtn() {
    return SizedBox(
      width: double.infinity,
      height: 48, // ลดจาก 50 เหลือ 48
      child: ElevatedButton(
        onPressed: _isLoading ? null : register,
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
                ? const SizedBox(
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
                  'ສ້າງບັນຊີ',
                  style: GoogleFonts.montserrat(
                    fontSize: 17, // ลดจาก 18 เหลือ 17
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D47A1),
                  ),
                ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return TextButton(
      onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8), // ลด padding
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            'ມີບັນຊີຢູ່ແລ້ວບໍ? ',
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 15, // ลดจาก 16 เหลือ 15
            ),
          ),
          Text(
            'ເຂົ້າສູ່ລະບົບ',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 15, // ลดจาก 16 เหลือ 15
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
