import 'dart:convert';
import 'package:BIBOL/config/bibol_api.dart';
import 'package:BIBOL/models/gallery/gallery_model.dart';
import 'package:BIBOL/models/gallery/gallery_response.dart';
import 'package:http/http.dart' as http;
// import 'package:your_project/models/gallery_model.dart';
// import 'package:your_project/config/api/gallert_api_config.dart';

class GalleryService {
  /// ดึงข้อมูล gallery items ของ user
  Future<GalleryResponse?> getUserGallery({
    required String userId,
    int page = 1,
    int count = 5,
  }) async {
    try {
      final url = Uri.parse(
        GalleryApiConfig.getUserTopics(userId, page, count),
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // เพิ่ม Authorization header ถ้าจำเป็น
          // 'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return GalleryResponse.fromJson(jsonData);
      } else {
        print('Error: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  /// ดึงข้อมูล gallery item เดียว
  Future<GalleryModel?> getGalleryById(String userId, int itemId) async {
    try {
      final url = Uri.parse(GalleryApiConfig.getTopicById(userId, itemId));

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return GalleryModel.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }
}
