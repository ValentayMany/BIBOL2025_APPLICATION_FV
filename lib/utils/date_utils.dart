// lib/utils/date_utils.dart

import 'package:intl/intl.dart';

/// 📅 Date Utility
/// Helper methods for date formatting and manipulation
class DateUtils {
  // Private constructor
  DateUtils._();

  /// ============================================
  /// DATE FORMATTING
  /// ============================================

  /// Format date to Lao format: dd/MM/yyyy
  static String formatLaoDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date to Lao format with time: dd/MM/yyyy HH:mm
  static String formatLaoDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Format date to short Lao format: dd MMM yyyy
  static String formatShortLaoDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format time only: HH:mm
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format date to ISO 8601: yyyy-MM-ddTHH:mm:ss
  static String formatISO(DateTime date) {
    return date.toIso8601String();
  }

  /// ============================================
  /// RELATIVE TIME FORMATTING
  /// ============================================

  /// Get relative time string (e.g., "2 ຊົ່ວໂມງກ່ອນ", "3 ມື້ກ່ອນ")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'ຫາກກີ້ນີ້';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ນາທີກ່ອນ';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ຊົ່ວໂມງກ່ອນ';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ມື້ກ່ອນ';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ອາທິດກ່ອນ';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ເດືອນກ່ອນ';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ປີກ່ອນ';
    }
  }

  /// ============================================
  /// DATE COMPARISON
  /// ============================================

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  /// Check if date is in current week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  /// Check if date is in current month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if date is in current year
  static bool isThisYear(DateTime date) {
    return date.year == DateTime.now().year;
  }

  /// ============================================
  /// DATE MANIPULATION
  /// ============================================

  /// Add days to date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Subtract days from date
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// ============================================
  /// PARSING
  /// ============================================

  /// Parse date from string (supports multiple formats)
  static DateTime? parseDate(String dateStr) {
    try {
      // Try ISO 8601 format first
      return DateTime.parse(dateStr);
    } catch (e) {
      try {
        // Try dd/MM/yyyy format
        return DateFormat('dd/MM/yyyy').parse(dateStr);
      } catch (e) {
        try {
          // Try yyyy-MM-dd format
          return DateFormat('yyyy-MM-dd').parse(dateStr);
        } catch (e) {
          return null;
        }
      }
    }
  }

  /// ============================================
  /// AGE CALCULATION
  /// ============================================

  /// Calculate age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  /// ============================================
  /// DURATION FORMATTING
  /// ============================================

  /// Format duration to readable string
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} ຊົ່ວໂມງ ${duration.inMinutes.remainder(60)} ນາທີ';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} ນາທີ';
    } else {
      return '${duration.inSeconds} ວິນາທີ';
    }
  }
}
