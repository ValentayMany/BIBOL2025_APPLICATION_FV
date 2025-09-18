// widgets/banner_slider_widget.dart
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../models/Banner_Models.dart';
import '../models/Banner_response.dart';
import '../services/Banner_service.dart';
import 'banner_item_widget.dart';
import 'banner_indicators_widget.dart';
import 'banner_navigation_widget.dart';
import 'banner_overlay_widget.dart';
import 'banner_states_widget.dart';

class BannerSliderWidget extends StatefulWidget {
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showIndicators;
  final bool showNavigationButtons;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry margin;
  final bool onlyActiveBanners;
  final VoidCallback? onRefresh;

  const BannerSliderWidget({
    Key? key,
    this.height = 200.0,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.showIndicators = true,
    this.showNavigationButtons = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.onlyActiveBanners = true,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<BannerSliderWidget> createState() => _BannerSliderWidgetState();
}

class _BannerSliderWidgetState extends State<BannerSliderWidget> {
  final PageController _pageController = PageController();
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentIndex = 0;
  ApiResponse<List<BannerModel>>? _lastResponse;

  @override
  void initState() {
    super.initState();
    _loadBanners();
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use new structured response approach
      final response =
          widget.onlyActiveBanners
              ? await BannerService.fetchActiveBanners()
              : await BannerService.fetchBanners();

      setState(() {
        _lastResponse = response;
        _isLoading = false;

        if (response.success && response.data != null) {
          _banners = response.data!;
          _errorMessage = null;
          debugPrint('✅ Successfully loaded ${_banners.length} banners');

          // Reset current index if it's out of bounds
          if (_currentIndex >= _banners.length) {
            _currentIndex = 0;
          }
        } else {
          _banners = [];
          _errorMessage = response.message;
          debugPrint('❌ Error loading banners: ${response.message}');
        }
      });

      // Call onRefresh callback if provided
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'เกิดข้อผิดพลาดที่ไม่คาดคิด: ${e.toString()}';
        _banners = [];
        _lastResponse = null;
      });
      debugPrint('❌ Unexpected error loading banners: $e');
    }
  }

  Future<void> _refreshBanners() async {
    debugPrint('🔄 Refreshing banners...');

    try {
      final response = await BannerService.refreshBanners();

      setState(() {
        _lastResponse = response;

        if (response.success && response.data != null) {
          _banners =
              widget.onlyActiveBanners
                  ? response.data!.where((banner) => banner.isActive).toList()
                  : response.data!;
          _errorMessage = null;
          debugPrint('✅ Successfully refreshed ${_banners.length} banners');
        } else {
          _errorMessage = response.message;
          debugPrint('❌ Error refreshing banners: ${response.message}');
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการรีเฟรช: ${e.toString()}';
      });
      debugPrint('❌ Error refreshing banners: $e');
    }
  }

  void _startAutoPlay() {
    if (!mounted || !widget.autoPlay) return;

    Future.delayed(widget.autoPlayInterval, () {
      if (mounted && _banners.isNotEmpty && widget.autoPlay) {
        final nextIndex = (_currentIndex + 1) % _banners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startAutoPlay(); // Continue auto play
      }
    });
  }

  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onBannerTapped(BannerModel banner) {
    debugPrint('🎯 Banner tapped: ${banner.displayTitle}');

    if (banner.hasLink) {
      debugPrint('🔗 Should navigate to: ${banner.linkUrl}');
      // TODO: Implement URL launching or navigation
      // Example:
      // await launchUrl(Uri.parse(banner.linkUrl!));

      // Or if it's internal navigation:
      // Navigator.pushNamed(context, banner.linkUrl!);
    } else {
      debugPrint('ℹ️ Banner has no link to navigate');
    }
  }

  void _navigateToPrevious() {
    if (_banners.isEmpty) return;

    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        _banners.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToNext() {
    if (_banners.isEmpty) return;

    if (_currentIndex < _banners.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToPage(int index) {
    if (index >= 0 && index < _banners.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: widget.margin,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return BannerLoadingWidget(
        height: widget.height,
        borderRadius: widget.borderRadius,
      );
    }

    if (_errorMessage != null) {
      return BannerErrorWidget(
        height: widget.height,
        borderRadius: widget.borderRadius,
        onRetry: _loadBanners,
        onRefresh: _refreshBanners,
        errorMessage: _errorMessage,
        lastResponse: _lastResponse,
      );
    }

    if (_banners.isEmpty) {
      return BannerEmptyWidget(
        height: widget.height,
        borderRadius: widget.borderRadius,
        onRefresh: _loadBanners,
      );
    }

    return _buildSlider();
  }

  Widget _buildSlider() {
    return Stack(
      children: [
        // Main Slider
        ClipRRect(
          borderRadius: widget.borderRadius,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return BannerItemWidget(
                banner: banner,
                height: widget.height,
                onTap: () => _onBannerTapped(banner),
              );
            },
          ),
        ),

        // Navigation Buttons
        if (widget.showNavigationButtons && _banners.length > 1)
          BannerNavigationWidget(
            onPrevious: _navigateToPrevious,
            onNext: _navigateToNext,
          ),

        // Indicators
        if (widget.showIndicators && _banners.length > 1)
          BannerIndicatorsWidget(
            itemCount: _banners.length,
            currentIndex: _currentIndex,
            onTap: _navigateToPage,
          ),

        // Title Overlay
        if (_banners.isNotEmpty && _currentIndex < _banners.length)
          BannerOverlayWidget(
            banner: _banners[_currentIndex],
            showIndicators: widget.showIndicators,
          ),

        // Debug Info Overlay (only in debug mode)
        if (kDebugMode) _buildDebugOverlay(),
      ],
    );
  }

  Widget _buildDebugOverlay() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Debug: ${_currentIndex + 1}/${_banners.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ========================================
// Enhanced Error Widget (extends the original)
// ========================================
class EnhancedBannerErrorWidget extends StatelessWidget {
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback onRetry;
  final VoidCallback? onRefresh;
  final String? errorMessage;
  final ApiResponse<List<BannerModel>>? lastResponse;

  const EnhancedBannerErrorWidget({
    Key? key,
    required this.height,
    required this.borderRadius,
    required this.onRetry,
    this.onRefresh,
    this.errorMessage,
    this.lastResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 12),
            Text(
              'ไม่สามารถโหลดแบนเนอร์ได้',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  errorMessage!,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('ลองใหม่'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                if (onRefresh != null) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.cached, size: 16),
                    label: const Text('รีเฟรช'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (kDebugMode && lastResponse != null) ...[
              const SizedBox(height: 8),
              Text(
                'Debug: Status ${lastResponse!.statusCode ?? 'Unknown'}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade500,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
