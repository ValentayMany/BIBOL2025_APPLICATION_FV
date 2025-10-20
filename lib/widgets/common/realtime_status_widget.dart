import 'package:flutter/material.dart';
import 'package:BIBOL/widgets/common/loading_indicators.dart';
import 'package:BIBOL/providers/simple_realtime_provider.dart';
import 'package:provider/provider.dart';

/// 🔄 Real-time Status Widget
///
/// Shows real-time connection status and loading states
class RealtimeStatusWidget extends StatelessWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const RealtimeStatusWidget({super.key, this.showDetails = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleRealtimeProvider>(
      builder: (context, realtimeProvider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getBackgroundColor(
                realtimeProvider.status,
                realtimeProvider.isLoading,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getBorderColor(
                  realtimeProvider.status,
                  realtimeProvider.isLoading,
                ),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusIcon(
                  realtimeProvider.status,
                  realtimeProvider.isLoading,
                ),
                const SizedBox(width: 8),
                _buildStatusText(realtimeProvider.status),
                if (showDetails) ...[
                  const SizedBox(width: 8),
                  _buildDetails(realtimeProvider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(String status, bool isLoading) {
    if (isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: LoadingIndicators.dotsLoading(color: Colors.orange, size: 4),
      );
    }

    IconData icon;
    Color color;

    switch (status.toLowerCase()) {
      case 'connected':
        icon = Icons.wifi;
        color = Colors.green;
        break;
      case 'checking for updates...':
        icon = Icons.sync;
        color = Colors.orange;
        break;
      case 'updates found!':
        icon = Icons.update;
        color = Colors.blue;
        break;
      case 'no updates':
        icon = Icons.check_circle_outline;
        color = Colors.grey;
        break;
      case 'error':
        icon = Icons.error_outline;
        color = Colors.red;
        break;
      default:
        icon = Icons.cloud_off;
        color = Colors.grey;
    }

    return Icon(icon, size: 16, color: color);
  }

  Widget _buildStatusText(String status) {
    return Text(
      status,
      style: TextStyle(
        fontSize: 12,
        color: _getTextColor(status),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDetails(SimpleRealtimeProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (provider.newsCount > 0) ...[
          Icon(Icons.article_outlined, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            '${provider.newsCount}',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
        ],
        if (provider.contactsCount > 0) ...[
          Icon(Icons.contact_phone_outlined, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            '${provider.contactsCount}',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Color _getBackgroundColor(String status, bool isLoading) {
    if (isLoading) return Colors.orange.withOpacity(0.1);

    switch (status.toLowerCase()) {
      case 'connected':
        return Colors.green.withOpacity(0.1);
      case 'checking for updates...':
        return Colors.orange.withOpacity(0.1);
      case 'updates found!':
        return Colors.blue.withOpacity(0.1);
      case 'error':
        return Colors.red.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getBorderColor(String status, bool isLoading) {
    if (isLoading) return Colors.orange.withOpacity(0.3);

    switch (status.toLowerCase()) {
      case 'connected':
        return Colors.green.withOpacity(0.3);
      case 'checking for updates...':
        return Colors.orange.withOpacity(0.3);
      case 'updates found!':
        return Colors.blue.withOpacity(0.3);
      case 'error':
        return Colors.red.withOpacity(0.3);
      default:
        return Colors.grey.withOpacity(0.3);
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
        return Colors.green;
      case 'checking for updates...':
        return Colors.orange;
      case 'updates found!':
        return Colors.blue;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// 🔄 Floating Real-time Status Widget
///
/// A floating widget that shows real-time status
class FloatingRealtimeStatusWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const FloatingRealtimeStatusWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 16,
      child: Consumer<SimpleRealtimeProvider>(
        builder: (context, realtimeProvider, child) {
          return AnimatedOpacity(
            opacity: realtimeProvider.isInitialized ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: RealtimeStatusWidget(showDetails: true, onTap: onTap),
          );
        },
      ),
    );
  }
}

/// 🔄 Real-time Loading Overlay
///
/// Shows loading overlay when real-time service is working
class RealtimeLoadingOverlay extends StatelessWidget {
  final Widget child;
  final String? customMessage;

  const RealtimeLoadingOverlay({
    super.key,
    required this.child,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleRealtimeProvider>(
      builder: (context, realtimeProvider, child) {
        return Stack(
          children: [
            if (realtimeProvider.isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LoadingIndicators.dotsLoading(
                          color: Colors.blue,
                          size: 6,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          customMessage ?? 'กำลังอัปเดตข้อมูล...',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
