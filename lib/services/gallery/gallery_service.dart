import 'dart:convert';
import 'package:BIBOL/config/bibol_api.dart';
import 'package:BIBOL/models/gallery/gallery_model.dart';
import 'package:BIBOL/models/gallery/gallery_response.dart';
import 'package:http/http.dart' as http;

/// 🖼️ GalleryService - Service สำหรับจัดการแกลเลอรี่
/// 
/// Service นี้ใช้สำหรับดึงข้อมูลภาพและแกลเลอรี่ของผู้ใช้
/// 
/// **ฟีเจอร์หลัก:**
/// - ดึงรายการ gallery items พร้อม pagination
/// - ดึง gallery item เดียวตาม ID
/// - รองรับ UTF-8 encoding
/// 
/// **ตัวอย่างการใช้งาน:**
/// ```dart
/// final galleryService = GalleryService();
/// 
/// // ดึง gallery ของ user
/// final gallery = await galleryService.getUserGallery(
///   userId: '123',
///   page: 1,
///   count: 10,
/// );
/// 
/// // ดึง gallery item เดียว
/// final item = await galleryService.getGalleryById('123', 456);
/// ```
class GalleryService {
  /// ดึงข้อมูล gallery items ของ user พร้อม pagination
  /// 
  /// **Parameters:**
  /// - [userId] - ID ของผู้ใช้ (required)
  /// - [page] - หมายเลขหน้า (default: 1)
  /// - [count] - จำนวนรายการต่อหน้า (default: 5)
  /// 
  /// **Returns:**
  /// - [GalleryResponse?] - ข้อมูล gallery หรือ null ถ้าเกิดข้อผิดพลาด
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
