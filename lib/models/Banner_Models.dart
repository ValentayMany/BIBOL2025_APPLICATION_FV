// models/Banner_Models.dart
class BannerModel {
  final int? id;
  final String? title;
  final String? details;
  final String? file;
  final String? videoType;
  final String? youtubeLink;
  final String? linkUrl;
  final String? icon;

  BannerModel({
    this.id,
    this.title,
    this.details,
    this.file,
    this.videoType,
    this.youtubeLink,
    this.linkUrl,
    this.icon,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'],
      details: json['details'],
      file: json['file'],
      videoType: json['video_type'],
      youtubeLink: json['youtube_link'],
      linkUrl: json['link_url'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'file': file,
      'video_type': videoType,
      'youtube_link': youtubeLink,
      'link_url': linkUrl,
      'icon': icon,
    };
  }

  // Helper getters
  bool get isActive => true; // ตาม API ไม่มี active field

  bool get hasTitle => title?.isNotEmpty == true;

  bool get hasDetails => details?.isNotEmpty == true;

  bool get hasImage => file?.isNotEmpty == true && file != 'noimg.png';

  bool get hasLink => linkUrl?.isNotEmpty == true && linkUrl != '#';

  bool get hasValidImage =>
      hasImage && file != null && !file!.contains('noimg.png');

  String get displayTitle => title ?? 'ไม่มีหัวข้อ';

  String get displayDetails => details ?? '';

  String get safeImageUrl => file ?? '';

  @override
  String toString() {
    return 'BannerModel(id: $id, title: $title, hasImage: $hasImage)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BannerModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
