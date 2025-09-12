import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:auth_flutter_api/screens/home_page.dart';
import 'package:auth_flutter_api/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _waveController;
  late AnimationController _shimmerController;
  late AnimationController _logoController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;

  @override
  void initState() {
    super.initState();

    // Enhanced rotation animation for background
    _rotationController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    // Smooth pulse animation for logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Staggered fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Elastic slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Wave animation for background effect
    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Shimmer effect for text
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    // Logo entrance animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Orchestrated animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Logo entrance
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Text fade in
    await Future.delayed(const Duration(milliseconds: 700));
    _fadeController.forward();

    // Text slide in
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _waveController.dispose();
    _shimmerController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: _buildSplashContent(),
      nextScreen: HomePage(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.rightToLeftWithFade,
      backgroundColor: const Color(0xFF0A1628),
      duration: 4000,
      splashIconSize: MediaQuery.of(context).size.height,
    );
  }

  Widget _buildSplashContent() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Enhanced Animated Background
          _buildModernBackground(),

          // Main Content with Glass Morphism Effect
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Enhanced Animated Logo
                  _buildAnimatedLogo(),
                  const SizedBox(height: 50),
                  // Enhanced Animated Title
                  _buildAnimatedTitle(),
                  const SizedBox(height: 40),
                  // Modern Loading Indicator
                  _buildModernLoader(),
                ],
              ),
            ),
          ),

          // Floating Action Elements
          _buildFloatingElements(),

          // Enhanced Bottom Info
          _buildBottomInfo(),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoScaleAnimation,
        _logoRotationAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value * _pulseAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Hero(
                    tag: 'app_logo',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/images/LOGO.png',
                        height: 160,
                        width: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Main Title with Shimmer Effect
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: const [
                        Colors.white60,
                        Colors.white,
                        Colors.white60,
                      ],
                      stops: [
                        0.0,
                        _shimmerAnimation.value.clamp(0.0, 1.0),
                        1.0,
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'ສະຖາບັນການທະນາຄານ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.blue.withOpacity(0.5),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Animated Subtitle
            Text(
              'Banking Institute',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Animated Underline
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Container(
                  width: 100 * _fadeController.value,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.blue.withOpacity(0.8),
                        Colors.white.withOpacity(0.8),
                        Colors.blue.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLoader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Custom Animated Progress Indicator
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                // Outer ring
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.withOpacity(0.8),
                    ),
                  ),
                ),
                // Inner pulsing dot
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 12 * _pulseAnimation.value,
                        height: 12 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white,
                              Colors.blue.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Initializing Experience...',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBackground() {
    return Stack(
      children: [
        // Base Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A1628),
                Color(0xFF1A2B47),
                Color(0xFF2D4A6B),
                Color(0xFF0F1B2E),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),

        // Animated Wave Pattern
        AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(_waveAnimation.value),
              size: Size.infinite,
            );
          },
        ),

        // Dynamic Circles with Enhanced Effects
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Large morphing circle
                Positioned(
                  top: -150,
                  left: -150,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blue.withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Medium circle with different rotation speed
                Positioned(
                  top: 150,
                  right: -120,
                  child: Transform.rotate(
                    angle: -_rotationAnimation.value * 1.5,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.cyan.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom floating circles
                Positioned(
                  bottom: -100,
                  left: -80,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * 0.8,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.lightBlue.withOpacity(0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: List.generate(20, (index) {
        return AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            final double animationValue =
                (_rotationController.value + index * 0.05) % 1.0;
            final double size = 2 + (index % 4) * 1.5;
            final double opacity =
                (math.sin(animationValue * math.pi * 2) * 0.4 + 0.3).abs();

            return Positioned(
              left: (50 + index * 37.0) % MediaQuery.of(context).size.width,
              top:
                  100 +
                  (animationValue * MediaQuery.of(context).size.height * 0.7) +
                  math.sin(animationValue * math.pi * 4) * 50,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.8),
                        Colors.blue.withOpacity(0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: size * 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '© 2025 Banking Institute',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
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
}

// Custom Wave Painter for Background Effect
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.withOpacity(0.05), Colors.transparent],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveHeight = 50.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x++) {
      final y =
          size.height * 0.7 +
          waveHeight *
              math.sin((x / waveLength + animationValue) * 2 * math.pi);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
