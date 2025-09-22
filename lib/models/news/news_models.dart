import 'package:BIBOL/models/topic/topic_model.dart' show Topic;

class NewsModel {
  final String msg;
  final String sectionId;
  final String sectionTitle;
  final int type;
  final int topicsCount;
  final List<Topic> topics;

  NewsModel({
    required this.msg,
    required this.sectionId,
    required this.sectionTitle,
    required this.type,
    required this.topicsCount,
    required this.topics,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      msg: json['msg']?.toString() ?? '',
      sectionId: json['section_id']?.toString() ?? '',
      sectionTitle: json['section_title']?.toString() ?? '',
      type: json['type']?.toInt() ?? 0,
      topicsCount: json['topics_count']?.toInt() ?? 0,
      topics: _parseTopics(json['topics']),
    );
  }

  // ✅ เพิ่ม: สำหรับกรณีที่ API ส่งมาเป็น Topic โดยตรง
  factory NewsModel.fromTopicJson(Map<String, dynamic> json) {
    // สร้าง Topic จาก JSON
    final topic = Topic.fromJson(json);

    return NewsModel(
      msg: 'success',
      sectionId: topic.sectionId ?? '',
      sectionTitle: topic.sectionTitle ?? '',
      type: 1,
      topicsCount: 1,
      topics: [topic],
    );
  }

  static List<Topic> _parseTopics(dynamic topicsData) {
    if (topicsData == null) return [];

    try {
      if (topicsData is List) {
        return topicsData
            .map((item) => Topic.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('❌ Error parsing topics: $e');
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'section_id': sectionId,
      'section_title': sectionTitle,
      'type': type,
      'topics_count': topicsCount,
      'topics': topics.map((topic) => topic.toJson()).toList(),
    };
  }

  // ✅ แก้ไข copyWith method (เอา list parameter ออก)
  NewsModel copyWith({
    String? msg,
    String? sectionId,
    String? sectionTitle,
    int? type,
    int? topicsCount,
    List<Topic>? topics,
  }) => NewsModel(
    msg: msg ?? this.msg,
    sectionId: sectionId ?? this.sectionId,
    sectionTitle: sectionTitle ?? this.sectionTitle,
    type: type ?? this.type,
    topicsCount: topicsCount ?? this.topicsCount,
    topics: topics ?? this.topics,
  );
}
