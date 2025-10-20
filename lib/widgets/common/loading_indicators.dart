import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🔄 Loading Indicators Widgets
/// 
/// Beautiful and reusable loading indicators for BIBOL App
class LoadingIndicators {
  /// 📰 News loading indicator
  static Widget newsLoading({
    String? message,
    double size = 50.0,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 🔄 Real-time status indicator
  static Widget realtimeStatus({
    required String status,
    bool isConnected = false,
  }) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'connected':
        statusColor = Colors.green;
        statusIcon = Icons.wifi;
        break;
      case 'checking for updates...':
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        break;
      case 'updates found!':
        statusColor = Colors.blue;
        statusIcon = Icons.update;
        break;
      case 'no updates':
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'error':
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.cloud_off;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔄 Pulse loading animation
  static Widget pulseLoading({
    String? message,
    Color color = Colors.blue,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 1),
            tween: Tween(begin: 0.5, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(value * 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              // Restart animation
            },
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 🔄 Shimmer loading effect
  static Widget shimmerLoading({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height ?? 20,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 1),
        tween: Tween(begin: -1.0, end: 1.0),
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[100]!,
                  Colors.grey[300]!,
                ],
                stops: [
                  0.0,
                  0.5 + value * 0.5,
                  1.0,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔄 Dots loading animation
  static Widget dotsLoading({
    Color color = Colors.blue,
    double size = 8.0,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 200)),
          tween: Tween(begin: 0.5, end: 1.0),
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  /// 🔄 News card skeleton loading
  static Widget newsCardSkeleton() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                shimmerLoading(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      shimmerLoading(width: double.infinity, height: 16),
                      const SizedBox(height: 4),
                      shimmerLoading(width: 120, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            shimmerLoading(width: double.infinity, height: 18),
            const SizedBox(height: 8),
            shimmerLoading(width: double.infinity, height: 18),
            const SizedBox(height: 8),
            shimmerLoading(width: 200, height: 18),
            const SizedBox(height: 16),
            Row(
              children: [
                shimmerLoading(width: 80, height: 12),
                const Spacer(),
                shimmerLoading(width: 60, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔄 Contact card skeleton loading
  static Widget contactCardSkeleton() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                shimmerLoading(
                  width: 50,
                  height: 50,
                  borderRadius: BorderRadius.circular(25),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      shimmerLoading(width: 150, height: 18),
                      const SizedBox(height: 8),
                      shimmerLoading(width: 200, height: 14),
                      const SizedBox(height: 4),
                      shimmerLoading(width: 180, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔄 Full screen loading
  static Widget fullScreenLoading({
    String? message,
    Widget? customIndicator,
  }) {
    return Container(
      color: Colors.white.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            customIndicator ?? 
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
