import 'dart:convert';
import 'dart:io';
import 'package:BIBOL/config/bibol_api.dart';
import 'package:BIBOL/models/news/news_response.dart' show NewsResponse;
import 'package:BIBOL/models/topic/topic_model.dart' show Topic;
import 'package:BIBOL/models/website/website_info_model.dart'
    show WebsiteInfoModel;
import 'package:http/http.dart' as http;

/// 📰 NewsService - Service สำหรับจัดการข่าวสารทั้งหมด
/// 
/// Service นี้ใช้สำหรับดึงข้อมูลข่าวสารจาก API และจัดการข้อมูลข่าว
/// 
/// **ฟีเจอร์หลัก:**
/// - ดึงรายการข่าวพร้อม pagination
/// - ดึงข่าวตาม ID
/// - ดึงข้อมูลเว็บไซต์
/// - รองรับ retry mechanism เมื่อ request ล้มเหลว
/// - Timeout protection (30 วินาที)
/// 
/// **ตัวอย่างการใช้งาน:**
/// ```dart
/// // ดึงข่าวหน้าแรก 10 ข่าว
/// final newsResponse = await NewsService.getNews(limit: 10, page: 1);
/// 
/// // ดึงข่าวตาม ID
/// final news = await NewsService.getNewsById('123');
/// 
/// // ดึงข้อมูลเว็บไซต์
/// final website = await NewsService.getWebsiteInfo();
/// ```
class NewsService {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  static Future<NewsResponse> getNews({
    int? limit,
    int? page,
    String? category,
  }) async {
    int retries = 0;

    while (retries < _maxRetries) {
      try {
        // ✅ ใช้ NewsApiConfig แทน ApiConfig
        final url = NewsApiConfig.getNewsUrl(
          page: page ?? 1,
          count: limit ?? 10,
        );
        print('🔍 Fetching news from: $url (attempt ${retries + 1})');

        final response = await http
            .get(Uri.parse(url), headers: _getHeaders())
            .timeout(_defaultTimeout);

        print('📡 News API Response Status: ${response.statusCode}');
        _logResponse(response);

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          return NewsResponse.fromJson(jsonData);
        } else if (response.statusCode >= 500 && retries < _maxRetries - 1) {
          retries++;
          await Future.delayed(Duration(seconds: retries * 2));
          continue;
        } else {
          throw HttpException(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          );
        }
      } catch (e) {
        print('❌ Error fetching news (attempt ${retries + 1}): $e');

        if (retries == _maxRetries - 1) {
          return NewsResponse(
            success: false,
            message: _getErrorMessage(e),
            data: [],
          );
        }

        retries++;
        await Future.delayed(Duration(seconds: retries));
      }
    }

    return NewsResponse(
      success: false,
      message: 'ไม่สามารถโหลดข่าวได้หลังจากพยายาม $_maxRetries ครั้ง',
      data: [],
    );
  }

  // ✅ แก้ไข getNewsById ให้ทำงานกับ API structure ที่แท้จริง
  static Future<Topic?> getNewsById(String id) async {
    try {
      // ตรวจสอบ ID ก่อน
      if (id.isEmpty) {
        print('❌ News ID is empty');
        return null;
      }

      final numericId = int.tryParse(id);
      if (numericId == null) {
        print('❌ Invalid news ID format: $id');
        return null;
      }

      // ✅ ใช้ list API แล้ว filter หา ID ที่ต้องการ
      final url = NewsApiConfig.getNewsByIdUrl(id);
      print('🔍 Fetching news from list API: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(_defaultTimeout);

      print('📡 News API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          print(
            '📊 JSON Structure keys: ${jsonData is Map ? jsonData.keys.toList() : 'Not a Map'}',
          );

          // ✅ Parse topics list และหา topic ที่มี ID ตรงกัน
          if (jsonData is Map &&
              jsonData['topics'] != null &&
              jsonData['topics'] is List) {
            final topics = jsonData['topics'] as List;
            print(
              '📝 Found ${topics.length} topics, searching for ID: $numericId',
            );

            for (var topicData in topics) {
              if (topicData is Map && topicData['id'] == numericId) {
                print('✅ Found matching topic: ${topicData['title']}');
                return Topic.fromJson(topicData as Map<String, dynamic>);
              }
            }

            print(
              '❌ Topic with ID $numericId not found in ${topics.length} topics',
            );
            // แสดง IDs ที่มี สำหรับ debug
            final availableIds =
                topics
                    .where((t) => t is Map && t['id'] != null)
                    .map((t) => t['id'])
                    .toList();
            print('📋 Available IDs: $availableIds');
            return null;
          } else {
            print('❌ No topics array found in response');
            return null;
          }
        } catch (parseError) {
          print('❌ JSON parsing error: $parseError');
          print('📄 Raw response: ${response.body.substring(0, 500)}...');
          return null;
        }
      } else {
        print('❌ HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('❌ Network/Connection error in getNewsById: $e');
      return null;
    }
  }

  // ✅ Helper method เพื่อ parse Topic จาก response แบบต่างๆ
  static Topic? _parseTopicFromResponse(dynamic jsonData) {
    try {
      // กรณีที่ 1: response เป็น topic object โดยตรง
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('id')) {
        print('📝 Parsing as direct topic object');
        return Topic.fromJson(jsonData);
      }

      // กรณีที่ 2: response มี key 'data' และข้างในเป็น topic
      if (jsonData is Map && jsonData['data'] != null) {
        print('📝 Parsing from data field');
        if (jsonData['data'] is Map<String, dynamic>) {
          return Topic.fromJson(jsonData['data']);
        } else if (jsonData['data'] is List && jsonData['data'].isNotEmpty) {
          return Topic.fromJson(jsonData['data'][0]);
        }
      }

      // กรณีที่ 3: response มี key 'topics' array
      if (jsonData is Map &&
          jsonData['topics'] != null &&
          jsonData['topics'] is List) {
        print('📝 Parsing from topics array');
        final topics = jsonData['topics'] as List;
        if (topics.isNotEmpty) {
          return Topic.fromJson(topics[0]);
        }
      }

      // กรณีที่ 4: response เป็น array โดยตรง
      if (jsonData is List && jsonData.isNotEmpty) {
        print('📝 Parsing from direct array');
        return Topic.fromJson(jsonData[0]);
      }

      // กรณีที่ 5: response มี key 'topic' (singular)
      if (jsonData is Map && jsonData['topic'] != null) {
        print('📝 Parsing from topic field');
        return Topic.fromJson(jsonData['topic']);
      }

      // กรณีที่ 6: response มี key 'result'
      if (jsonData is Map && jsonData['result'] != null) {
        print('📝 Parsing from result field');
        if (jsonData['result'] is Map<String, dynamic>) {
          return Topic.fromJson(jsonData['result']);
        }
      }

      print('❌ No recognized topic structure found in response');
      return null;
    } catch (e) {
      print('❌ Error in _parseTopicFromResponse: $e');
      return null;
    }
  }

  static Future<NewsResponse> searchNews(
    String keyword, {
    int? limit,
    int? page,
  }) async {
    try {
      if (keyword.trim().isEmpty) {
        return NewsResponse(
          success: false,
          message: 'กรุณาใส่คำค้นหา',
          data: [],
        );
      }

      // ใช้ getNewsUrl แทน newsSearchUrl
      final url = NewsApiConfig.getNewsUrl(
        page: page ?? 1,
        count: limit ?? 50,
        search: keyword.trim(),
      );

      print('🔍 Searching news with URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(_defaultTimeout);

      print('📡 Search API Response Status: ${response.statusCode}');
      _logResponse(response);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NewsResponse.fromJson(jsonData);
      } else {
        throw HttpException('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error searching news: $e');
      return NewsResponse(
        success: false,
        message: _getErrorMessage(e),
        data: [],
      );
    }
  }

  static Future<WebsiteInfoModel?> getWebsiteInfo() async {
    try {
      final url = NewsApiConfig.websiteInfoUrl;
      print('🔍 Fetching website info from: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(_defaultTimeout);

      print('📡 Website Info API Response Status: ${response.statusCode}');
      _logResponse(response);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['details'] != null) {
          return WebsiteInfoModel.fromJson(jsonData['details']);
        } else if (jsonData['data'] != null) {
          return WebsiteInfoModel.fromJson(jsonData['data']);
        } else if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('site_url')) {
          return WebsiteInfoModel.fromJson(jsonData);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error fetching website info: $e');
      return null;
    }
  }

  // Helper methods
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Flutter App/1.0',
    };
  }

  static void _logResponse(http.Response response) {
    if (response.body.length > 500) {
      print('📄 Response Body: ${response.body.substring(0, 500)}...');
    } else {
      print('📄 Response Body: ${response.body}');
    }
  }

  static String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'ບໍ່ສາມາດເຊື່ອມຕໍ່ອິນເຕີເນັດໄດ້';
    } else if (error is HttpException) {
      return 'ເຊີບເວີບໍ່ສາມາດຕອບສະໜອງໄດ້';
    } else if (error is FormatException) {
      return 'ຂໍ້ມູນທີ່ໄດ້ຮັບບໍ່ຖືກຕ້ອງ';
    } else if (error.toString().contains('TimeoutException')) {
      return 'ໝົດເວລາໃນການເຊື່ອມຕໍ່';
    }
    return 'ເກີດຂໍ້ຜິດພາດທີ່ບໍ່ຄາດຄິດ: ${error.toString()}';
  }

  // Other methods
  static Future<bool> testConnection() async {
    try {
      final url = NewsApiConfig.getNewsUrl(count: 1);
      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(const Duration(seconds: 10));

      print('📡 Connection test result: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ News API connection error: $e');
      return false;
    }
  }

  static Future<NewsResponse> getNewsByCategory(
    String category, {
    int? limit,
    int? page,
  }) async {
    return getNews(category: category, limit: limit, page: page);
  }

  static Future<NewsResponse> getNewsWithPagination({
    required int page,
    int limit = 10,
    String? category,
  }) async {
    return getNews(page: page, limit: limit, category: category);
  }

  static Future<NewsResponse> refreshNews() async {
    print('🔄 Refreshing news...');
    return getNews(limit: 20, page: 1);
  }

  // ✅ เพิ่ม method สำหรับ debug API response
  static Future<void> debugNewsApi(String id) async {
    print('🐛 DEBUG: Testing news API with ID: $id');
    try {
      final url = NewsApiConfig.getNewsByIdUrl(id);
      print('🐛 DEBUG URL: $url');

      final response = await http.get(Uri.parse(url), headers: _getHeaders());

      print('🐛 DEBUG Status: ${response.statusCode}');
      print('🐛 DEBUG Headers: ${response.headers}');
      print('🐛 DEBUG Body Length: ${response.body.length}');
      print('🐛 DEBUG Body: ${response.body}');
    } catch (e) {
      print('🐛 DEBUG Error: $e');
    }
  }
}
