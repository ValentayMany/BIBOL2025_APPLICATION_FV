import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:BIBOL/widgets/common/loading_indicators.dart';

/// 🔄 Pull-to-Refresh Widget
///
/// Beautiful and customizable pull-to-refresh widget for BIBOL App
class PullToRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshText;
  final String? releaseText;
  final String? loadingText;
  final Color? primaryColor;
  final Color? backgroundColor;
  final double? displacement;
  final bool showRefreshIndicator;

  const PullToRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText,
    this.releaseText,
    this.loadingText,
    this.primaryColor,
    this.backgroundColor,
    this.displacement,
    this.showRefreshIndicator = true,
  });

  @override
  State<PullToRefreshWidget> createState() => _PullToRefreshWidgetState();
}

class _PullToRefreshWidgetState extends State<PullToRefreshWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  // ignore: unused_field
  late Animation<double> _animation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.primaryColor ?? Theme.of(context).primaryColor,
      backgroundColor: widget.backgroundColor ?? Colors.white,
      displacement: widget.displacement ?? 40.0,
      child: widget.child,
    );
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      _controller.forward();
      await widget.onRefresh();
    } catch (e) {
      // Handle error if needed
      print('❌ Refresh error: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
      _controller.reset();
    }
  }
}

/// 🔄 Custom Pull-to-Refresh Indicator
class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshText;
  final String? releaseText;
  final String? loadingText;
  final Color? primaryColor;
  final Color? backgroundColor;
  final double? displacement;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText,
    this.releaseText,
    this.loadingText,
    this.primaryColor,
    this.backgroundColor,
    this.displacement,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: primaryColor ?? Theme.of(context).primaryColor,
      backgroundColor: backgroundColor ?? Colors.white,
      displacement: displacement ?? 40.0,
      child: child,
    );
  }
}

/// 🔄 Animated Pull-to-Refresh Widget
class AnimatedPullToRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshText;
  final String? releaseText;
  final String? loadingText;
  final Color? primaryColor;
  final Color? backgroundColor;
  final double? displacement;

  const AnimatedPullToRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText,
    this.releaseText,
    this.loadingText,
    this.primaryColor,
    this.backgroundColor,
    this.displacement,
  });

  @override
  State<AnimatedPullToRefreshWidget> createState() =>
      _AnimatedPullToRefreshWidgetState();
}

class _AnimatedPullToRefreshWidgetState
    extends State<AnimatedPullToRefreshWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  // ignore: unused_field
  late Animation<double> _rotationAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.primaryColor ?? Theme.of(context).primaryColor,
      backgroundColor: widget.backgroundColor ?? Colors.white,
      displacement: widget.displacement ?? 40.0,
      child: widget.child,
    );
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      _controller.forward();
      await widget.onRefresh();
    } catch (e) {
      print('❌ Refresh error: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
      _controller.reset();
    }
  }
}

/// 🔄 News Pull-to-Refresh Widget
class NewsPullToRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? customText;

  const NewsPullToRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.customText,
  });

  @override
  State<NewsPullToRefreshWidget> createState() =>
      _NewsPullToRefreshWidgetState();
}

class _NewsPullToRefreshWidgetState extends State<NewsPullToRefreshWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.blue,
      backgroundColor: Colors.white,
      displacement: 40.0,
      child: widget.child,
    );
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      _controller.forward();
      await widget.onRefresh();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  widget.customText ?? 'ອັດເດດຂ່າວສານສຳເລັດແລ້ວ',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'ເກີດຂໍ້ຜິດພາດໃນການອັບເດດ',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });
      _controller.reset();
    }
  }
}

/// 🔄 Contacts Pull-to-Refresh Widget
class ContactsPullToRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const ContactsPullToRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<ContactsPullToRefreshWidget> createState() =>
      _ContactsPullToRefreshWidgetState();
}

class _ContactsPullToRefreshWidgetState
    extends State<ContactsPullToRefreshWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.green,
      backgroundColor: Colors.white,
      displacement: 40.0,
      child: widget.child,
    );
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      _controller.forward();
      await widget.onRefresh();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'ອັບເດດຂໍໍ້ມູນຕິດຕໍ່ແລ້ວ',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'ເກີດຂໍ້ຜິດພາດໃນການອັບເດດຂໍໍ້ມູນຕິດຕໍ່',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });
      _controller.reset();
    }
  }
}

/// 🔄 Courses Pull-to-Refresh Widget
class CoursesPullToRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const CoursesPullToRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<CoursesPullToRefreshWidget> createState() =>
      _CoursesPullToRefreshWidgetState();
}

class _CoursesPullToRefreshWidgetState extends State<CoursesPullToRefreshWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.purple,
      backgroundColor: Colors.white,
      displacement: 40.0,
      child: widget.child,
    );
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      _controller.forward();
      await widget.onRefresh();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'ອັບເດດຫລັກສູດສຳເລັດ',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'ເກີດຂໍ້ຜິດພາດໃນການອັບເດດຫລັກສູດ',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });
      _controller.reset();
    }
  }
}
