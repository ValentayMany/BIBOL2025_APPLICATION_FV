import 'package:BIBOL/models/gallery/gallery_model.dart';

class GalleryResponse {
  final String msg;
  final String userId;
  final String userName;
  final int topicsCount;
  final List<GalleryModel> topics;

  GalleryResponse({
    required this.msg,
    required this.userId,
    required this.userName,
    required this.topicsCount,
    required this.topics,
  });

  factory GalleryResponse.fromJson(Map<String, dynamic> json) {
    return GalleryResponse(
      msg: json['msg'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? '',
      topicsCount: json['topics_count'] ?? 0,
      topics:
          (json['topics'] as List<dynamic>?)
              ?.map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'user_id': userId,
      'user_name': userName,
      'topics_count': topicsCount,
      'topics': topics.map((e) => e.toJson()).toList(),
    };
  }
}
