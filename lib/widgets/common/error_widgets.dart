import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:BIBOL/services/error/error_handler_service.dart';

/// 🚨 Error Display Widgets
///
/// Beautiful error widgets for BIBOL App
class ErrorWidgets {
  /// 📱 Full screen error widget
  static Widget fullScreenError({
    required AppError error,
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getErrorColor(error.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(error.icon, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 24),

              // Error title
              Text(
                _getErrorTitle(error.type),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getErrorColor(error.type),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Error message
              Text(
                customMessage ?? error.userFriendlyMessage,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Retry button
              if (onRetry != null && error.shouldRetry)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('ลองใหม่'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getErrorColor(error.type),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

              // Technical details (debug mode)
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Info:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Type: ${error.type}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (error.statusCode != null)
                        Text(
                          'Status: ${error.statusCode}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      if (error.operationName != null)
                        Text(
                          'Operation: ${error.operationName}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      Text(
                        'Time: ${error.timestamp.toString()}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 📱 Inline error widget
  static Widget inlineError({
    required AppError error,
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getErrorColor(error.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getErrorColor(error.type).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Error icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getErrorColor(error.type).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(error.icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 16),

          // Error content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getErrorTitle(error.type),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getErrorColor(error.type),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customMessage ?? error.userFriendlyMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Retry button
          if (onRetry != null && error.shouldRetry)
            IconButton(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, color: _getErrorColor(error.type)),
              tooltip: 'ลองใหม่',
            ),
        ],
      ),
    );
  }

  /// 📱 Snackbar error
  static void showErrorSnackBar(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(error.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                customMessage ?? error.userFriendlyMessage,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error.type),
        duration: const Duration(seconds: 4),
        action:
            onRetry != null && error.shouldRetry
                ? SnackBarAction(
                  label: 'ລອງໃໝ່',
                  textColor: Colors.white,
                  onPressed: onRetry,
                )
                : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// 📱 Loading error widget
  static Widget loadingError({required AppError error, VoidCallback? onRetry}) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getErrorIconData(error.type),
            size: 48,
            color: _getErrorColor(error.type),
          ),
          const SizedBox(height: 16),
          Text(
            _getErrorTitle(error.type),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getErrorColor(error.type),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error.userFriendlyMessage,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null && error.shouldRetry) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('ລອງໃໝ່'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getErrorColor(error.type),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 📱 Connection error widget
  static Widget connectionError({
    VoidCallback? onRetry,
    VoidCallback? onCheckSettings,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'ບໍ່ມີສັນຢານອິນເຕີເນັດ',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'ກະລຸນາກວດສອບອິນເຕີເນັດຂອງທ່ານ',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('ລອງໃໝ່'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              if (onCheckSettings != null)
                OutlinedButton.icon(
                  onPressed: onCheckSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('ຕັ້ງຄ່າ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  static Color _getErrorColor(String errorType) {
    switch (errorType) {
      case ErrorHandlerService.networkError:
        return Colors.orange;
      case ErrorHandlerService.timeoutError:
        return Colors.red;
      case ErrorHandlerService.apiError:
        return Colors.red;
      case ErrorHandlerService.parsingError:
        return Colors.purple;
      case ErrorHandlerService.authError:
        return Colors.blue;
      case ErrorHandlerService.serverError:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String _getErrorTitle(String errorType) {
    switch (errorType) {
      case ErrorHandlerService.networkError:
        return 'ປັນຫາການເຊື່ອມຕໍ່';
      case ErrorHandlerService.timeoutError:
        return 'ໝົດເວລາ';
      case ErrorHandlerService.apiError:
        return 'ຂໍໍ້ຜິດພາດ API';
      case ErrorHandlerService.parsingError:
        return 'ຂໍໍ້ຜິດພາດຂໍໍ້ມູນ';
      case ErrorHandlerService.authError:
        return 'ຂໍໍ້ຜິດພາດການເຂົ້າສູ່ລະບົບ';
      case ErrorHandlerService.serverError:
        return 'ປັນຫາຂອງເຊິີຟເວີ';
      default:
        return 'ເກີດຂໍ້ຜິດພາດ';
    }
  }

  static IconData _getErrorIconData(String errorType) {
    switch (errorType) {
      case ErrorHandlerService.networkError:
        return Icons.wifi_off;
      case ErrorHandlerService.timeoutError:
        return Icons.timer_off;
      case ErrorHandlerService.apiError:
        return Icons.error_outline;
      case ErrorHandlerService.parsingError:
        return Icons.bug_report;
      case ErrorHandlerService.authError:
        return Icons.lock_outline;
      case ErrorHandlerService.serverError:
        return Icons.dns_outlined;
      default:
        return Icons.error;
    }
  }
}
