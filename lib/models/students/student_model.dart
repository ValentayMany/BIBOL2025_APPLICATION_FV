class StudentLoginResponse {
  final bool success;
  final Student? data;
  final String? message;
  final String? token;

  StudentLoginResponse({
    required this.success,
    this.data,
    this.message,
    this.token,
  });

  factory StudentLoginResponse.fromJson(Map<String, dynamic> json) {
    return StudentLoginResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? Student.fromJson(json['data']) : null,
      message: json['message'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'token': token,
    };
  }
}

class Student {
  final int id;
  final int parentId;
  final String admissionNo;
  final String rollNo;
  final DateTime? admissionDate;
  final String firstname;
  final String middlename;
  final String lastname;
  final String? image;
  final String mobileno;
  final String email;
  final String? religion;
  final DateTime? dob;
  final String gender;
  final String isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Student({
    required this.id,
    required this.parentId,
    required this.admissionNo,
    required this.rollNo,
    this.admissionDate,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    this.image,
    required this.mobileno,
    required this.email,
    this.religion,
    this.dob,
    required this.gender,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstname $middlename $lastname'.trim();

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: _parseInt(json['id']),
      parentId: _parseInt(json['parent_id']),
      admissionNo: _parseString(json['admission_no']),
      rollNo: _parseString(json['roll_no']),
      admissionDate: _parseDateTime(json['admission_date']),
      firstname: _parseString(json['firstname']),
      middlename: _parseString(json['middlename']),
      lastname: _parseString(json['lastname']),
      image: json['image']?.toString(),
      mobileno: _parseString(json['mobileno']),
      email: _parseString(json['email']),
      religion: json['religion']?.toString(),
      dob: _parseDateTime(json['dob']),
      gender: _parseString(json['gender']),
      isActive: _parseString(json['is_active']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  // Helper methods for safe parsing
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'admission_no': admissionNo,
      'roll_no': rollNo,
      'admission_date': admissionDate?.toIso8601String(),
      'firstname': firstname,
      'middlename': middlename,
      'lastname': lastname,
      'image': image,
      'mobileno': mobileno,
      'email': email,
      'religion': religion,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
