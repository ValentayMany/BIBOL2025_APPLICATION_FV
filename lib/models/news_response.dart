import 'news_model.dart';

class NewsResponse {
  final bool success;
  final String? message;
  final List<NewsModel> data;
  final int? total;

  NewsResponse({
    required this.success,
    this.message,
    required this.data,
    this.total,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    List<NewsModel> newsList = [];

    try {
      // ✅ แก้ไข: รองรับรูปแบบ API ที่แตกต่างกัน
      if (json['topics'] != null && json['topics'] is List) {
        // กรณี API ส่งมาเป็น topics array
        newsList =
            (json['topics'] as List)
                .map((item) => NewsModel.fromTopicJson(item))
                .toList();
      } else if (json['data'] != null && json['data'] is List) {
        // กรณี API ส่งมาเป็น data array
        newsList =
            (json['data'] as List)
                .map((item) => NewsModel.fromJson(item))
                .toList();
      } else if (json is List) {
        // กรณี API ส่งมาเป็น array โดยตรง
        newsList =
            (json as List).map((item) => NewsModel.fromJson(item)).toList();
      }
    } catch (e) {
      print('❌ Error parsing news data: $e');
    }

    return NewsResponse(
      success: json['success'] ?? true,
      message: json['msg']?.toString() ?? json['message']?.toString(),
      data: newsList,
      total:
          json['topics_count']?.toInt() ??
          json['total']?.toInt() ??
          newsList.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((news) => news.toJson()).toList(),
      'total': total,
    };
  }

  // Helper methods
  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
  int get length => data.length;

  NewsResponse merge(NewsResponse other) {
    return NewsResponse(
      success: success && other.success,
      message: message ?? other.message,
      data: [...data, ...other.data],
      total: (total ?? 0) + (other.total ?? 0),
    );
  }
}
