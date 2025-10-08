// lib/utils/validators.dart

/// 📋 Form Validators
/// Reusable form validation methods
class Validators {
  // Private constructor
  Validators._();

  /// ============================================
  /// TEXT VALIDATORS
  /// ============================================

  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? 'ກະລຸນາປ້ອນ$fieldName' : 'ກະລຸນາປ້ອນຂໍ້ມູນ';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ກະລຸນາປ້ອນອີເມວ';
    }

    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'ອີເມວບໍ່ຖືກຕ້ອງ';
    }

    return null;
  }

  /// Validate phone number (Laos format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ກະລຸນາປ້ອນເບີໂທລະສັບ';
    }

    // Remove spaces and special characters
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Laos phone number: 20xxxxxxxx (10 digits starting with 20)
    final phoneRegex = RegExp(r'^(20|030)\d{7,8}$');

    if (!phoneRegex.hasMatch(cleaned)) {
      return 'เบີໂທລະສັບບໍ່ຖືກຕ້ອງ (ເລີ່ມດ້ວຍ 20 ຫຼື 030)';
    }

    return null;
  }

  /// Validate password
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາປ້ອນລະຫັດຜ່ານ';
    }

    if (value.length < minLength) {
      return 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ $minLength ຕົວອັກສອນ';
    }

    return null;
  }

  /// Validate password with confirmation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'ກະລຸນາຢືນຢັນລະຫັດຜ່ານ';
    }

    if (value != password) {
      return 'ລະຫັດຜ່ານບໍ່ກົງກັນ';
    }

    return null;
  }

  /// Validate admission number
  static String? admissionNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ກະລຸນາປ້ອນລະຫັດນັກຮຽນ';
    }

    // Admission number should be alphanumeric and at least 3 characters
    if (value.trim().length < 3) {
      return 'ລະຫັດນັກຮຽນບໍ່ຖືກຕ້ອງ';
    }

    return null;
  }

  /// ============================================
  /// NUMBER VALIDATORS
  /// ============================================

  /// Validate number
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? 'ກະລຸນາປ້ອນ$fieldName' : 'ກະລຸນາປ້ອນຕົວເລກ';
    }

    if (double.tryParse(value) == null) {
      return 'ກະລຸນາປ້ອນຕົວເລກທີ່ຖືກຕ້ອງ';
    }

    return null;
  }

  /// Validate integer
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'ກະລຸນາປ້ອນ$fieldName'
          : 'ກະລຸນາປ້ອນຕົວເລກຈຳນວນເຕັມ';
    }

    if (int.tryParse(value) == null) {
      return 'ກະລຸນາປ້ອນຕົວເລກຈຳນວນເຕັມທີ່ຖືກຕ້ອງ';
    }

    return null;
  }

  /// Validate number in range
  static String? numberInRange(
    String? value, {
    required double min,
    required double max,
    String? fieldName,
  }) {
    final numError = number(value, fieldName: fieldName);
    if (numError != null) return numError;

    final num = double.parse(value!);
    if (num < min || num > max) {
      return 'ຕ້ອງຢູ່ລະຫວ່າງ $min ແລະ $max';
    }

    return null;
  }

  /// ============================================
  /// TEXT LENGTH VALIDATORS
  /// ============================================

  /// Validate minimum length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? 'ກະລຸນາປ້ອນ$fieldName' : 'ກະລຸນາປ້ອນຂໍ້ມູນ';
    }

    if (value.length < min) {
      return 'ຕ້ອງມີຢ່າງໜ້ອຍ $min ຕົວອັກສອນ';
    }

    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return 'ຕ້ອງບໍ່ເກີນ $max ຕົວອັກສອນ';
    }

    return null;
  }

  /// Validate length in range
  static String? lengthInRange(
    String? value,
    int min,
    int max, {
    String? fieldName,
  }) {
    final minError = minLength(value, min, fieldName: fieldName);
    if (minError != null) return minError;

    final maxError = maxLength(value, max, fieldName: fieldName);
    if (maxError != null) return maxError;

    return null;
  }

  /// ============================================
  /// URL VALIDATORS
  /// ============================================

  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ກະລຸນາປ້ອນ URL';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'URL ບໍ່ຖືກຕ້ອງ';
    }

    return null;
  }

  /// ============================================
  /// DATE VALIDATORS
  /// ============================================

  /// Validate date is not in future
  static String? notFutureDate(DateTime? date) {
    if (date == null) {
      return 'ກະລຸນາເລືອກວັນທີ';
    }

    if (date.isAfter(DateTime.now())) {
      return 'ບໍ່ສາມາດເລືອກວັນທີໃນອະນາຄົດໄດ້';
    }

    return null;
  }

  /// Validate date is not in past
  static String? notPastDate(DateTime? date) {
    if (date == null) {
      return 'ກະລຸນາເລືອກວັນທີ';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isBefore(today)) {
      return 'ບໍ່ສາມາດເລືອກວັນທີໃນອະດີດໄດ້';
    }

    return null;
  }

  /// ============================================
  /// COMPOSITE VALIDATORS
  /// ============================================

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
