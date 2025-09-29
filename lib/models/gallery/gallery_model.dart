class GalleryModel {
  final int id;
  final String title;
  final String details;
  final String date;
  final String? videoType;
  final String videoFile;
  final String photoFile;
  final String? audioFile;
  final String icon;
  final int visits;
  final String href;
  final int fieldsCount;
  final List<dynamic> fields;
  final int joinedCategoriesCount;
  final List<dynamic> joinedCategories;
  final int sectionId;
  final String? sectionName;
  final int sectionType;

  GalleryModel({
    required this.id,
    required this.title,
    required this.details,
    required this.date,
    this.videoType,
    required this.videoFile,
    required this.photoFile,
    this.audioFile,
    required this.icon,
    required this.visits,
    required this.href,
    required this.fieldsCount,
    required this.fields,
    required this.joinedCategoriesCount,
    required this.joinedCategories,
    required this.sectionId,
    this.sectionName,
    required this.sectionType,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      details: json['details'] ?? '',
      date: json['date'] ?? '',
      videoType: json['video_type'],
      videoFile: json['video_file'] ?? '',
      photoFile: json['photo_file'] ?? '',
      audioFile: json['audio_file'],
      icon: json['icon'] ?? '',
      visits: json['visits'] ?? 0,
      href: json['href'] ?? '',
      fieldsCount: json['fields_count'] ?? 0,
      fields: json['fields'] ?? [],
      joinedCategoriesCount: json['Joined_categories_count'] ?? 0,
      joinedCategories: json['Joined_categories'] ?? [],
      sectionId: json['section_id'] ?? 0,
      sectionName: json['section_name'],
      sectionType: json['section_type'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'date': date,
      'video_type': videoType,
      'video_file': videoFile,
      'photo_file': photoFile,
      'audio_file': audioFile,
      'icon': icon,
      'visits': visits,
      'href': href,
      'fields_count': fieldsCount,
      'fields': fields,
      'Joined_categories_count': joinedCategoriesCount,
      'Joined_categories': joinedCategories,
      'section_id': sectionId,
      'section_name': sectionName,
      'section_type': sectionType,
    };
  }
}
