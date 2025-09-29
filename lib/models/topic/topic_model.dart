// ignore_for_file: avoid_print

import 'package:BIBOL/models/topic/joined_category_model.dart'
    show JoinedCategory;
import 'package:BIBOL/models/user/user_model.dart' show User;

class Topic {
  final int id;
  final String title;
  final String details;
  final DateTime date;
  final dynamic videoType;
  final String videoFile;
  final String photoFile;
  final dynamic audioFile;
  final dynamic icon;
  final int visits;
  final String href;
  final int fieldsCount;
  final List<dynamic> fields;
  final int joinedCategoriesCount;
  final List<JoinedCategory> joinedCategories;
  final User user;
  final String? sectionTitle;
  final String? sectionId;

  Topic({
    required this.id,
    required this.title,
    required this.details,
    required this.date,
    required this.videoType,
    required this.videoFile,
    required this.photoFile,
    required this.audioFile,
    required this.icon,
    required this.visits,
    required this.href,
    required this.fieldsCount,
    required this.fields,
    required this.joinedCategoriesCount,
    required this.joinedCategories,
    required this.user,
    this.sectionTitle,
    this.sectionId,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    // แปลง date string เป็น DateTime
    DateTime parseDate(dynamic dateData) {
      try {
        if (dateData is String) {
          if (dateData.isEmpty) return DateTime.now();
          return DateTime.parse(dateData);
        } else if (dateData is int) {
          return DateTime.fromMillisecondsSinceEpoch(dateData * 1000);
        }
      } catch (e) {
        print('❌ Error parsing date: $dateData, error: $e');
      }
      return DateTime.now();
    }

    // ✅ แก้ไข: รองรับทั้ง Joined_categories และ joined_categories
    List<JoinedCategory> parseJoinedCategories(dynamic categoriesData) {
      try {
        if (categoriesData is List) {
          final categories = <JoinedCategory>[];
          for (var item in categoriesData) {
            try {
              if (item is Map<String, dynamic>) {
                categories.add(JoinedCategory.fromJson(item));
              }
            } catch (e) {
              print('❌ Error parsing individual category: $item, error: $e');
            }
          }
          print('✅ Parsed ${categories.length} categories successfully');
          return categories;
        }
      } catch (e) {
        print('❌ Error parsing joined categories: $e');
      }
      return [];
    }

    // แปลง User
    User parseUser(dynamic userData) {
      try {
        if (userData is Map<String, dynamic>) {
          return User.fromJson(userData);
        }
      } catch (e) {
        print('❌ Error parsing user: $userData, error: $e');
      }
      return User.fromJson({});
    }

    // แปลง fields
    List<dynamic> parseFields(dynamic fieldsData) {
      try {
        if (fieldsData is List) {
          return fieldsData;
        }
      } catch (e) {
        print('❌ Error parsing fields: $e');
      }
      return [];
    }

    try {
      // ✅ Debug: พิมพ์ข้อมูลที่สำคัญ
      print('🔍 Parsing Topic ID: ${json['id']}, Title: ${json['title']}');

      // ✅ ลองหา categories ทั้ง 2 รูปแบบ
      dynamic categoriesData =
          json['Joined_categories'] ?? json['joined_categories'];
      print('🔍 Categories data type: ${categoriesData.runtimeType}');
      print('🔍 Categories data: $categoriesData');

      final parsedCategories = parseJoinedCategories(categoriesData);
      print('✅ Final parsed categories count: ${parsedCategories.length}');

      return Topic(
        id: _parseInt(json['id']) ?? 0,
        title: _parseString(json['title']) ?? '',
        details: _parseString(json['details']) ?? '',
        date: parseDate(json['date']),
        videoType: json['video_type'],
        videoFile: _parseString(json['video_file']) ?? '',
        photoFile: _parseString(json['photo_file']) ?? '',
        audioFile: json['audio_file'],
        icon: json['icon'],
        visits: _parseInt(json['visits']) ?? 0,
        href: _parseString(json['href']) ?? '',
        fieldsCount: _parseInt(json['fields_count']) ?? 0,
        fields: parseFields(json['fields']),
        joinedCategoriesCount:
            _parseInt(
              json['Joined_categories_count'] ??
                  json['joined_categories_count'],
            ) ??
            0,
        joinedCategories: parsedCategories,
        user: parseUser(json['user']),
        sectionTitle: _parseString(json['section_title']),
        sectionId: _parseString(json['section_id']),
      );
    } catch (e) {
      print('❌ Error creating Topic from JSON: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'date': date.toIso8601String(),
      'video_type': videoType,
      'video_file': videoFile,
      'photo_file': photoFile,
      'audio_file': audioFile,
      'icon': icon,
      'visits': visits,
      'href': href,
      'fields_count': fieldsCount,
      'fields': fields,
      'joined_categories_count': joinedCategoriesCount,
      'joined_categories': joinedCategories.map((cat) => cat.toJson()).toList(),
      'user': user.toJson(),
      'section_title': sectionTitle,
      'section_id': sectionId,
    };
  }

  Topic copyWith({
    int? id,
    String? title,
    String? details,
    DateTime? date,
    dynamic videoType,
    String? videoFile,
    String? photoFile,
    dynamic audioFile,
    dynamic icon,
    int? visits,
    String? href,
    int? fieldsCount,
    List<dynamic>? fields,
    int? joinedCategoriesCount,
    List<JoinedCategory>? joinedCategories,
    User? user,
    String? sectionTitle,
    String? sectionId,
  }) => Topic(
    id: id ?? this.id,
    title: title ?? this.title,
    details: details ?? this.details,
    date: date ?? this.date,
    videoType: videoType ?? this.videoType,
    videoFile: videoFile ?? this.videoFile,
    photoFile: photoFile ?? this.photoFile,
    audioFile: audioFile ?? this.audioFile,
    icon: icon ?? this.icon,
    visits: visits ?? this.visits,
    href: href ?? this.href,
    fieldsCount: fieldsCount ?? this.fieldsCount,
    fields: fields ?? this.fields,
    joinedCategoriesCount: joinedCategoriesCount ?? this.joinedCategoriesCount,
    joinedCategories: joinedCategories ?? this.joinedCategories,
    user: user ?? this.user,
    sectionTitle: sectionTitle ?? this.sectionTitle,
    sectionId: sectionId ?? this.sectionId,
  );

  // Helper methods for safe parsing
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString().isEmpty ? null : value.toString();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    if (value is double) return value.toInt();
    return null;
  }

  // Helper methods for UI
  bool get hasImage => photoFile.isNotEmpty;
  bool get hasVideo => videoFile.isNotEmpty;
  bool get hasValidDate => date.isAfter(DateTime(2000));

  String get displayTitle => title.isEmpty ? 'ບໍ່ມີຫົວຂໍ້' : title;
  String get displayDetails {
    if (details.isEmpty) return 'ບໍ່ມີເນື້ອຫາ';
    // Strip HTML tags for display
    return details.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  @override
  String toString() {
    return 'Topic(id: $id, title: "$title", categories: ${joinedCategories.length}, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Topic && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
