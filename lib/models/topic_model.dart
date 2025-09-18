import 'package:BIBOL/models/joined_category_model.dart';
import 'package:BIBOL/models/user_model.dart';

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

  var sectionTitle;

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
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    // แปลง date string เป็น DateTime
    DateTime parseDate(dynamic dateData) {
      if (dateData is String) {
        try {
          return DateTime.parse(dateData);
        } catch (e) {
          return DateTime.now();
        }
      } else if (dateData is int) {
        // กรณีที่เป็น timestamp
        return DateTime.fromMillisecondsSinceEpoch(dateData * 1000);
      }
      return DateTime.now();
    }

    // แปลง joinedCategories
    List<JoinedCategory> parseJoinedCategories(dynamic categoriesData) {
      if (categoriesData is List) {
        return categoriesData
            .map(
              (item) => JoinedCategory.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    }

    return Topic(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      details: json['details'] ?? '',
      date: parseDate(json['date']),
      videoType: json['video_type'],
      videoFile: json['video_file'] ?? '',
      photoFile: json['photo_file'] ?? '',
      audioFile: json['audio_file'],
      icon: json['icon'],
      visits: json['visits'] ?? 0,
      href: json['href'] ?? '',
      fieldsCount: json['fields_count'] ?? 0,
      fields: json['fields'] ?? [],
      joinedCategoriesCount: json['joined_categories_count'] ?? 0,
      joinedCategories: parseJoinedCategories(json['joined_categories']),
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  get sectionId => null;

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
  );
}
