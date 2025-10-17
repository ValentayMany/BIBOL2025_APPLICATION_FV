// lib/models/website/contact_model.dart
class ContactModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? mobile;
  final String? fax;
  final String? address;
  final String? workingTime;
  final String? website;
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? youtube;
  final String? description;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ContactModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.mobile,
    this.fax,
    this.address,
    this.workingTime,
    this.website,
    this.facebook,
    this.instagram,
    this.twitter,
    this.youtube,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    // ✅ Debug print to see incoming data
    print('🔍 ContactModel.fromJson - Raw JSON: $json');
    print('🔍 ContactModel.fromJson - phone: ${json['phone']}');
    print('🔍 ContactModel.fromJson - mobile: ${json['mobile']}');

    return ContactModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'BIBOL Institute',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      mobile: json['mobile']?.toString(),
      fax: json['fax']?.toString(),
      address: json['address']?.toString(),
      workingTime: json['working_time']?.toString(),
      website: json['website']?.toString(),
      facebook: json['facebook']?.toString(),
      instagram: json['instagram']?.toString(),
      twitter: json['twitter']?.toString(),
      youtube: json['youtube']?.toString(),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'fax': fax,
      'address': address,
      'working_time': workingTime,
      'website': website,
      'facebook': facebook,
      'instagram': instagram,
      'twitter': twitter,
      'youtube': youtube,
      'description': description,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ✅ Helper methods - ปรับปรุงให้ชัดเจนขึ้น
  bool get hasPhone {
    final result =
        (phone != null && phone!.trim().isNotEmpty) ||
        (mobile != null && mobile!.trim().isNotEmpty);
    print('🔍 hasPhone: $result (phone: $phone, mobile: $mobile)');
    return result;
  }

  bool get hasEmail => email != null && email!.trim().isNotEmpty;
  bool get hasAddress => address != null && address!.trim().isNotEmpty;
  bool get hasWorkingTime =>
      workingTime != null && workingTime!.trim().isNotEmpty;
  bool get hasFax => fax != null && fax!.trim().isNotEmpty;
  bool get hasSocialMedia =>
      (facebook != null && facebook!.trim().isNotEmpty) ||
      (instagram != null && instagram!.trim().isNotEmpty) ||
      (twitter != null && twitter!.trim().isNotEmpty) ||
      (youtube != null && youtube!.trim().isNotEmpty);

  // ✅ Get primary phone number - แก้ไขให้ชัดเจน
  String? get primaryPhone {
    // ลำดับความสำคัญ: mobile > phone
    if (mobile != null && mobile!.trim().isNotEmpty) {
      print('🔍 primaryPhone: using mobile = $mobile');
      return mobile!.trim();
    }
    if (phone != null && phone!.trim().isNotEmpty) {
      print('🔍 primaryPhone: using phone = $phone');
      return phone!.trim();
    }
    print('🔍 primaryPhone: no phone available');
    return null;
  }

  // ✅ Get formatted phone number - แก้ไขให้ชัดเจน
  String get formattedPhone {
    final phoneToFormat = primaryPhone;
    print('🔍 formattedPhone: phoneToFormat = $phoneToFormat');

    if (phoneToFormat == null || phoneToFormat.isEmpty) {
      print('🔍 formattedPhone: returning empty');
      return '';
    }

    // ถ้ามีเบอร์อยู่แล้ว ให้ใช้เลย (API ส่งมาในรูปแบบที่ถูกต้องแล้ว)
    print('🔍 formattedPhone: returning $phoneToFormat');
    return phoneToFormat;
  }

  // ✅ Alternative: Get both phones if available
  String get allPhones {
    final phones = <String>[];

    if (phone != null && phone!.trim().isNotEmpty) {
      phones.add('โทร: ${phone!.trim()}');
    }
    if (mobile != null && mobile!.trim().isNotEmpty && mobile != phone) {
      phones.add('มือถือ: ${mobile!.trim()}');
    }

    final result = phones.isEmpty ? 'ບໍ່ມີຂໍ້ມູນ' : phones.join(' | ');
    print('🔍 allPhones: $result');
    return result;
  }

  // Get display name
  String get displayName => name ?? 'BIBOL Institute';

  @override
  String toString() {
    return 'ContactModel(name: $name, phone: $phone, mobile: $mobile, hasPhone: $hasPhone, formattedPhone: $formattedPhone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
