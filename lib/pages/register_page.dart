import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
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
  // bool _isLoadingDropdowns = false;
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
      _showErrorSnackBar("Passwords do not match");
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
          apiMessage.isNotEmpty ? apiMessage : "Register failed",
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        message = "Connection error. Please try again.";
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
                  'Registration Successful!',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Your account has been created successfully. You can now sign in with your credentials.',
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
                      'Go to Login',
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
                        : "Registration failed. Please check your information."),
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
                'By creating an account, you agree to our Terms of Service and Privacy Policy. Please read them carefully before proceeding with registration.',
                style: GoogleFonts.montserrat(color: Colors.white70),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
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
          // Main Content - Fixed layout constraints
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        constraints.maxWidth > 600
                            ? (constraints.maxWidth - 600) / 2
                            : 24.0,
                    vertical: 16.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
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
                                // Logo
                                Hero(
                                  tag: 'app_logo',
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxHeight: 100,
                                      maxWidth: 100,
                                    ),
                                    child: Image.asset(
                                      'assets/images/LOGO.png',
                                      height: 100,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Title
                                Text(
                                  'Create Account',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),

                                // Subtitle
                                Text(
                                  'Join our banking community',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 30),

                                // Form Container
                                _buildGlassmorphicContainer(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        _buildCodeTF(),
                                        const SizedBox(height: 16),

                                        // Name Row with flexible layout
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            if (constraints.maxWidth > 400) {
                                              return Row(
                                                children: [
                                                  Expanded(
                                                    child: _buildNameTF(),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: _buildLastnameTF(),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Column(
                                                children: [
                                                  _buildNameTF(),
                                                  const SizedBox(height: 16),
                                                  _buildLastnameTF(),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        _buildNumberTF(),
                                        const SizedBox(height: 16),

                                        // Dropdown Row with flexible layout
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            if (constraints.maxWidth > 400) {
                                              return Row(
                                                children: [
                                                  const SizedBox(width: 16),
                                                ],
                                              );
                                            } else {
                                              return Column(
                                                children: [
                                                  // _buildMajorDropdown(),
                                                  const SizedBox(height: 16),
                                                  // _buildYearDropdown(),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        _buildPasswordTF(),
                                        const SizedBox(height: 16),
                                        _buildConfirmPasswordTF(),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildTermsCheckbox(),
                                const SizedBox(height: 20),
                                _buildRegisterBtn(),
                                const SizedBox(height: 20),
                                _buildLoginBtn(),
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
                        'Creating account...',
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
          padding: const EdgeInsets.all(20),
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
          return 'Please enter your code';
        }
        return null;
      },
      decoration: _buildInputDecoration(
        labelText: 'Student Code',
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
          return 'Required';
        }
        return null;
      },
      decoration: _buildInputDecoration(
        labelText: 'First Name',
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
          return 'Required';
        }
        return null;
      },
      decoration: _buildInputDecoration(
        labelText: 'Last Name',
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
          return 'Please enter your phone number';
        }
        if (value.length < 8) {
          return 'Phone number must be at least 8 digits';
        }
        return null;
      },
      decoration: _buildInputDecoration(
        labelText: 'Phone Number',
        prefixIcon: FontAwesomeIcons.phone,
      ),
    );
  }

  // Widget _buildMajorDropdown() {
  //   if (_isLoadingDropdowns || majors.isEmpty) {
  //     return Container(
  //       height: 56,
  //       decoration: BoxDecoration(
  //         color: Colors.white.withOpacity(0.2),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: const Center(
  //         child: SizedBox(
  //           width: 20,
  //           height: 20,
  //           child: CircularProgressIndicator(
  //             strokeWidth: 2,
  //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   return DropdownButtonFormField<int>(
  //     value: selectedMajorId,
  //     isExpanded: true,
  //     style: const TextStyle(color: Colors.white),
  //     dropdownColor: const Color(0xFF1A237E),
  //     validator: (value) {
  //       if (value == null) {
  //         return 'Please select major';
  //       }
  //       return null;
  //     },
  //     decoration: _buildInputDecoration(
  //       labelText: 'Major',
  //       prefixIcon: FontAwesomeIcons.graduationCap,
  //     ),
  //     items:
  //         majors.map((major) {
  //           return DropdownMenuItem<int>(
  //             value: major['id'],
  //             child: Text(
  //               major['name'] ?? 'Unknown Major',
  //               style: GoogleFonts.montserrat(
  //                 color: Colors.white,
  //                 fontSize: 14,
  //               ),
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           );
  //         }).toList(),
  //     onChanged: (value) {
  //       setState(() {
  //         selectedMajorId = value!;
  //       });
  //     },
  //   );
  // }

  // Widget _buildYearDropdown() {
  //   if (_isLoadingDropdowns || years.isEmpty) {
  //     return Container(
  //       height: 56,
  //       decoration: BoxDecoration(
  //         color: Colors.white.withOpacity(0.2),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: const Center(
  //         child: SizedBox(
  //           width: 20,
  //           height: 20,
  //           child: CircularProgressIndicator(
  //             strokeWidth: 2,
  //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   return DropdownButtonFormField<int>(
  //     value: selectedYearId,
  //     isExpanded: true,
  //     style: const TextStyle(color: Colors.white),
  //     dropdownColor: const Color(0xFF1A237E),
  //     validator: (value) {
  //       if (value == null) {
  //         return 'Please select year';
  //       }
  //       return null;
  //     },
  //     decoration: _buildInputDecoration(
  //       labelText: 'Year',
  //       prefixIcon: FontAwesomeIcons.calendar,
  //     ),
  //     items:
  //         years.map((year) {
  //           return DropdownMenuItem<int>(
  //             value: year['id'],
  //             child: Text(
  //               year['name'] ?? 'Unknown Year',
  //               style: GoogleFonts.montserrat(
  //                 color: Colors.white,
  //                 fontSize: 14,
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //     onChanged: (value) {
  //       setState(() {
  //         selectedYearId = value!;
  //       });
  //     },
  //   );
  // }

  Widget _buildPasswordTF() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      decoration: _buildInputDecoration(
        labelText: 'Password',
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
        labelText: 'Confirm Password',
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

  // Centralized input decoration method
  InputDecoration _buildInputDecoration({
    required String labelText,
    required dynamic prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: Colors.white70, size: 20),
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
      errorStyle: GoogleFonts.montserrat(color: Colors.red[300], fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: _showTermsDialog,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              'By registering, you agree to our ',
              style: GoogleFonts.montserrat(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              'Terms & Conditions',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 12,
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
      height: 50,
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
                  'Create Account',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
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
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            'Already have an Account? ',
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 16),
          ),
          Text(
            'Sign In',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
