import 'package:BIBOL/screens/Home/home_page.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Animation Controllers - Optimized for better performance
  late AnimationController _primaryController;
  late AnimationController _backgroundController;
  late AnimationController _transitionController;

  // Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar to transparent for immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Primary animation controller for main content
    _primaryController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Background animation controller
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Transition controller for smooth exit
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo animations - staggered and smooth
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Title animations - cascading effect
    _titleSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );

    // Subtitle animation
    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Loading animation
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Background animations
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  void _startAnimationSequence() async {
    // Start the main animation sequence
    _primaryController.forward();

    // Add haptic feedback for better user experience
    await Future.delayed(const Duration(milliseconds: 500));
    HapticFeedback.lightImpact();

    // Auto navigate after animation completes
    await Future.delayed(
      const Duration(milliseconds: 3500),
    ); // รอให้ animation เสร็จ
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Smooth transition out
    await _transitionController.forward();

    // Navigate with custom transition
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _backgroundController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final mediaQuery = MediaQuery.of(context);

    // Enhanced screen detection
    final isSmallScreen = screenSize.height < 700;
    final isVerySmallScreen = screenSize.height < 600;
    final isTablet = screenSize.shortestSide >= 600;
    final isLandscape = screenSize.width > screenSize.height;
    final textScaleFactor = mediaQuery.textScaleFactor;

    // Dynamic scaling based on screen type
    final scaleFactor = isTablet ? 1.3 : (isVerySmallScreen ? 0.8 : 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: AnimatedBuilder(
        animation: _transitionController,
        builder: (context, child) {
          return Opacity(
            opacity: 1.0 - _transitionController.value,
            child: _buildSplashContent(
              screenSize,
              isSmallScreen,
              scaleFactor,
              isTablet,
              isLandscape,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSplashContent(
    Size screenSize,
    bool isSmallScreen,
    double scaleFactor,
    bool isTablet,
    bool isLandscape,
  ) {
    return Stack(
      children: [
        // Enhanced Background
        _buildResponsiveBackground(screenSize),

        // Main Content
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * (isTablet ? 0.15 : 0.08),
                  vertical: isSmallScreen ? 20 : 40,
                ),
                child:
                    isLandscape && !isTablet
                        ? _buildLandscapeLayout(scaleFactor)
                        : _buildPortraitLayout(isSmallScreen, scaleFactor),
              ),
            ),
          ),
        ),

        // Bottom Info
        _buildResponsiveBottomInfo(screenSize),

        // Particles Effect
        _buildParticleEffect(screenSize),
      ],
    );
  }

  Widget _buildPortraitLayout(bool isSmallScreen, double scaleFactor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo Section
        _buildResponsiveLogo(isSmallScreen, scaleFactor),

        SizedBox(height: (isSmallScreen ? 30 : 50) * scaleFactor),

        // Title Section
        _buildResponsiveTitle(isSmallScreen, scaleFactor),

        SizedBox(height: (isSmallScreen ? 25 : 40) * scaleFactor),

        // Loading Section
        _buildResponsiveLoader(),
      ],
    );
  }

  Widget _buildLandscapeLayout(double scaleFactor) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildResponsiveLogo(false, scaleFactor * 0.8),
              const SizedBox(height: 20),
              _buildResponsiveLoader(),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildResponsiveTitle(false, scaleFactor * 0.9)],
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveBackground(Size screenSize) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A1628),
                const Color(0xFF1A2B47),
                const Color(0xFF2D4A6B).withOpacity(0.8),
                const Color(0xFF0F1B2E),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: ModernWavePainter(_backgroundAnimation.value),
            size: screenSize,
          ),
        );
      },
    );
  }

  Widget _buildResponsiveLogo(bool isSmallScreen, double scaleFactor) {
    double logoSize = ((isSmallScreen ? 120 : 160) * scaleFactor).clamp(
      80,
      200,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_logoScaleAnimation, _logoFadeAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoFadeAnimation,
          child: Transform.scale(
            scale: _logoScaleAnimation.value,
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(-2, -2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Hero(
                    tag: 'app_logo',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/LOGO.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.account_balance,
                              size: logoSize * 0.5,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          );
                        },
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

  Widget _buildResponsiveTitle(bool isSmallScreen, double scaleFactor) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _titleSlideAnimation,
        _titleFadeAnimation,
        _subtitleAnimation,
      ]),
      builder: (context, child) {
        return Column(
          children: [
            // Main Title
            Transform.translate(
              offset: Offset(0, _titleSlideAnimation.value),
              child: FadeTransition(
                opacity: _titleFadeAnimation,
                child: Text(
                  'ສະຖາບັນການທະນາຄານ',
                  style: GoogleFonts.notoSansLao(
                    fontSize: ((isSmallScreen ? 24 : 28) * scaleFactor).clamp(
                      18,
                      36,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 4,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: isSmallScreen ? 8 : 12),

            // Subtitle
            FadeTransition(
              opacity: _subtitleAnimation,
              child: Text(
                'Banking Institute',
                style: GoogleFonts.montserrat(
                  fontSize: ((isSmallScreen ? 14 : 16) * scaleFactor).clamp(
                    12,
                    20,
                  ),
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Animated Underline
            FadeTransition(
              opacity: _subtitleAnimation,
              child: AnimatedBuilder(
                animation: _subtitleAnimation,
                builder: (context, child) {
                  return Container(
                    width: 80 * _subtitleAnimation.value,
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveLoader() {
    return FadeTransition(
      opacity: _loadingAnimation,
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              children: [
                // Outer Progress Ring
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.withOpacity(0.7),
                    ),
                  ),
                ),
                // Center Dot
                Center(
                  child: AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale:
                            1.0 +
                            math.sin(
                                  _backgroundController.value * 4 * math.pi,
                                ) *
                                0.2,
                        child: Container(
                          width: 8,
                          height: 8,
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
                                color: Colors.blue.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please wait...',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveBottomInfo(Size screenSize) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _subtitleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.08), Colors.transparent],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Version 1.0.0',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                '© 2025 Banking Institute',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticleEffect(Size screenSize) {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundAnimation, _particleAnimation]),
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final double progress =
                (_backgroundAnimation.value + index * 0.08) % 1.0;
            final double opacity = (_particleAnimation.value *
                    (math.sin(progress * math.pi * 2) * 0.3 + 0.4))
                .clamp(0.0, 1.0);
            final double size = 1.5 + (index % 3) * 0.8;

            return Positioned(
              left: (30 + index * 28.0) % screenSize.width,
              top:
                  80 +
                  (progress * screenSize.height * 0.6) +
                  math.sin(progress * math.pi * 6) * 30,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.6),
                        Colors.blue.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// Optimized Wave Painter with better performance
class ModernWavePainter extends CustomPainter {
  final double animationValue;

  ModernWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.withOpacity(0.03), Colors.transparent],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveHeight = size.height * 0.05; // Responsive wave height
    final waveLength = size.width * 0.8;

    path.moveTo(0, size.height * 0.75);

    for (double x = 0; x <= size.width; x += 2) {
      // Optimize by reducing points
      final y =
          size.height * 0.75 +
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
