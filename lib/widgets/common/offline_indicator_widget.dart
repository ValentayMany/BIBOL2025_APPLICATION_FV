import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:BIBOL/services/offline/offline_service.dart';

/// 📱 Offline Indicator Widget
///
/// Beautiful offline mode indicator for BIBOL App
class OfflineIndicatorWidget extends StatefulWidget {
  final bool showWhenOnline;
  final bool showWhenOffline;
  final Color? onlineColor;
  final Color? offlineColor;
  final Duration animationDuration;

  const OfflineIndicatorWidget({
    super.key,
    this.showWhenOnline = false,
    this.showWhenOffline = true,
    this.onlineColor,
    this.offlineColor,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<OfflineIndicatorWidget> createState() => _OfflineIndicatorWidgetState();
}

class _OfflineIndicatorWidgetState extends State<OfflineIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: OfflineService.instance.connectivityStream,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        final shouldShow =
            (isOnline && widget.showWhenOnline) ||
            (!isOnline && widget.showWhenOffline);

        if (shouldShow && !_animationController.isCompleted) {
          _animationController.forward();
        } else if (!shouldShow && _animationController.isCompleted) {
          _animationController.reverse();
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value * 50),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isOnline
                            ? (widget.onlineColor ?? Colors.green)
                            : (widget.offlineColor ?? Colors.orange),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isOnline ? Icons.wifi : Icons.wifi_off,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOnline
                            ? 'ເຊື່ອມຕໍ່ອິນເຕີເນັດ'
                            : 'ບໍ່ມີສັຍຍານອິນເຕີເນັດ',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// 📱 Floating Offline Banner
class FloatingOfflineBanner extends StatefulWidget {
  final Widget child;
  final Color? offlineColor;
  final Duration animationDuration;

  const FloatingOfflineBanner({
    super.key,
    required this.child,
    this.offlineColor,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<FloatingOfflineBanner> createState() => _FloatingOfflineBannerState();
}

class _FloatingOfflineBannerState extends State<FloatingOfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _heightAnimation = Tween<double>(begin: 0.0, end: 40.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: OfflineService.instance.connectivityStream,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        if (!isOnline && !_animationController.isCompleted) {
          _animationController.forward();
        } else if (isOnline && _animationController.isCompleted) {
          _animationController.reverse();
        }

        return Column(
          children: [
            AnimatedBuilder(
              animation: _heightAnimation,
              builder: (context, child) {
                return Container(
                  height: _heightAnimation.value,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.offlineColor ?? Colors.orange,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child:
                      _heightAnimation.value > 0
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.wifi_off,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ໂໝດອອຟໄລນ',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                          : null,
                );
              },
            ),
            Expanded(child: widget.child),
          ],
        );
      },
    );
  }
}

/// 📱 Offline Status Card
class OfflineStatusCard extends StatelessWidget {
  final bool isOnline;
  final VoidCallback? onRetry;
  final VoidCallback? onViewCachedData;

  const OfflineStatusCard({
    super.key,
    required this.isOnline,
    this.onRetry,
    this.onViewCachedData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              size: 48,
              color: isOnline ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              isOnline ? 'ເຊື່ອມຕໍ່ອິນເຕີເນັດ' : 'ປິດໂມດອອຟໄລນ',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isOnline ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isOnline
                  ? 'ທ່ານສາມາດເຂົາເຖິງຂໍໍ້ມູນທີ່ອອນລາຍ'
                  : 'ກຳລັງແສດງຂໍໍ້ມູນທີ່ເກັບໄວ້ໃນເຄື່ອງ',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isOnline && onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('ລອງໃໝ່'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (onViewCachedData != null)
                  OutlinedButton.icon(
                    onPressed: onViewCachedData,
                    icon: const Icon(Icons.storage),
                    label: const Text('ເບິ່ງຂໍໍ້ມູນ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 📱 Offline Mode Toggle
class OfflineModeToggle extends StatelessWidget {
  final bool isOfflineModeEnabled;
  final ValueChanged<bool> onChanged;

  const OfflineModeToggle({
    super.key,
    required this.isOfflineModeEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.storage, color: Colors.blue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ໂຫມດອອຟໄລນ',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'ເກັບຂໍໍ້ມູນໄວ້ໃນເຄື່ອງເພື່ອໃຊ້ງານເມື່ອບໍ່ມີອິນເຕີເນັດ',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isOfflineModeEnabled,
              onChanged: onChanged,
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

/// 📱 Cache Status Widget
class CacheStatusWidget extends StatelessWidget {
  final Map<String, dynamic> cacheStats;
  final VoidCallback? onClearCache;
  final VoidCallback? onSync;

  const CacheStatusWidget({
    super.key,
    required this.cacheStats,
    this.onClearCache,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'ສະຖານນະແຄສ',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              'ສະຖານະເນັດ',
              (cacheStats['isOnline'] ?? false) ? 'ອອນລາຍ' : 'ອອຟໄລນ',
            ),
            _buildStatusRow(
              'ຂໍໍ້ມູນຂ່າວ',
              (cacheStats['newsCached'] ?? false) ? 'ມີ' : 'ບໍ່ມີ',
            ),
            _buildStatusRow(
              'ຄອສເຮຽນ',
              (cacheStats['coursesCached'] ?? false) ? 'ມີ' : 'ບໍ່ມີ',
            ),
            _buildStatusRow(
              'ຂໍໍ້ມູນຕິດຕໍ່',
              (cacheStats['contactsCached'] ?? false) ? 'ມີ' : 'ບໍ່ມີ',
            ),
            _buildStatusRow(
              'ຂະບວນດັດແຄສ',
              '${(cacheStats['cacheSize'] ?? 0) ~/ 1024} KB',
            ),
            if (cacheStats['lastSync'] != null)
              _buildStatusRow('ຊິງລ່າສຸດ', cacheStats['lastSync']),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onSync != null)
                  ElevatedButton.icon(
                    onPressed: onSync,
                    icon: const Icon(Icons.sync),
                    label: const Text('ຊີງ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (onClearCache != null)
                  OutlinedButton.icon(
                    onPressed: onClearCache,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('ລ້າງແຄສ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
