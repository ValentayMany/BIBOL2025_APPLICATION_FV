// widgets/banner_states_widget.dart
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../../models/banner/banner_response.dart';

// ========================================
// Loading State Widget
// ========================================
class BannerLoadingWidget extends StatelessWidget {
  final double height;
  final BorderRadius borderRadius;

  const BannerLoadingWidget({
    Key? key,
    required this.height,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'กำลังโหลดแบนเนอร์...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// Error State Widget
// ========================================
class BannerErrorWidget extends StatelessWidget {
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback onRetry;
  final VoidCallback? onRefresh;
  final String? errorMessage;
  final ApiResponse<List<dynamic>>? lastResponse;

  const BannerErrorWidget({
    Key? key,
    required this.height,
    required this.borderRadius,
    required this.onRetry,
    this.onRefresh,
    this.errorMessage,
    this.lastResponse,
  }) : super(key: key);

  String _getDisplayMessage() {
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return errorMessage!;
    }
    if (lastResponse != null) {
      return lastResponse!.message;
    }
    return 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';
  }

  IconData _getErrorIcon() {
    final statusCode = lastResponse?.statusCode;
    if (statusCode != null) {
      switch (statusCode) {
        case 404:
          return Icons.search_off;
        case 403:
          return Icons.lock;
        case 500:
        case 502:
        case 503:
          return Icons.dns;
        default:
          return Icons.error_outline;
      }
    }

    final message = _getDisplayMessage().toLowerCase();
    if (message.contains('เชื่อมต่อ') || message.contains('อินเทอร์เน็ต')) {
      return Icons.wifi_off;
    } else if (message.contains('หมดเวลา')) {
      return Icons.timer_off;
    }

    return Icons.error_outline;
  }

  MaterialColor _getErrorColor() {
    final statusCode = lastResponse?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return Colors.orange; // Server error
    }
    return Colors.red; // Client error or unknown
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = _getErrorColor();

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: errorColor.shade50,
        borderRadius: borderRadius,
        border: Border.all(color: errorColor.shade200),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getErrorIcon(), color: errorColor.shade400, size: 48),
              const SizedBox(height: 12),
              Text(
                'ไม่สามารถโหลดแบนเนอร์ได้',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: errorColor.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getDisplayMessage(),
                style: TextStyle(fontSize: 12, color: errorColor.shade600),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('ลองใหม่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorColor.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                    ),
                  ),
                  if (onRefresh != null)
                    OutlinedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.cached, size: 16),
                      label: const Text('รีเฟรช'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: errorColor.shade400,
                        side: BorderSide(color: errorColor.shade200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
              if (kDebugMode) _buildDebugInfo(errorColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugInfo(MaterialColor errorColor) {
    final statusCode = lastResponse?.statusCode;
    final hasDebugInfo = statusCode != null || lastResponse != null;

    if (!hasDebugInfo) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: errorColor.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: errorColor.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🐛 Debug Info:',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: errorColor.shade700,
            ),
          ),
          const SizedBox(height: 4),
          if (statusCode != null)
            Text(
              'Status Code: $statusCode',
              style: TextStyle(
                fontSize: 9,
                color: errorColor.shade600,
                fontFamily: 'monospace',
              ),
            ),
          if (lastResponse != null)
            Text(
              'Success: ${lastResponse!.success}',
              style: TextStyle(
                fontSize: 9,
                color: errorColor.shade600,
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
  }
}

// ========================================
// Empty State Widget
// ========================================
class BannerEmptyWidget extends StatelessWidget {
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback? onRefresh;

  const BannerEmptyWidget({
    Key? key,
    required this.height,
    required this.borderRadius,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'ไม่มีแบนเนอร์ให้แสดง',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ยังไม่มีแบนเนอร์ในระบบขณะนี้',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('รีเฟรช'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  side: BorderSide(color: Colors.grey.shade200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ========================================
// Network Status Widget (optional)
// ========================================
class BannerNetworkStatusWidget extends StatelessWidget {
  final bool isOnline;
  final VoidCallback? onRetry;

  const BannerNetworkStatusWidget({
    Key? key,
    required this.isOnline,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOnline) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('ลองใหม่'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ========================================
// Success Status Widget (optional)
// ========================================
class BannerSuccessStatusWidget extends StatefulWidget {
  final String message;
  final Duration displayDuration;

  const BannerSuccessStatusWidget({
    Key? key,
    required this.message,
    this.displayDuration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<BannerSuccessStatusWidget> createState() =>
      _BannerSuccessStatusWidgetState();
}

class _BannerSuccessStatusWidgetState extends State<BannerSuccessStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade700,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
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
}
