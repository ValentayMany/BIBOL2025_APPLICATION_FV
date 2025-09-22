import 'dart:convert';
import 'dart:io';
import 'package:BIBOL/config/news/news_api_config.dart';
import 'package:BIBOL/models/news/news_respones.dart' show NewsResponse;
import 'package:BIBOL/models/topic/topic_model.dart' show Topic;
import 'package:BIBOL/models/website/website_info_model.dart'
    show WebsiteInfoModel;
import 'package:http/http.dart' as http;

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

  static Future<Topic?> getNewsById(String id) async {
    try {
      final url = NewsApiConfig.getNewsByIdUrl(id);
      print('🔍 Fetching news by ID from: $url');

      final response = await http
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(_defaultTimeout);

      print('📡 News by ID API Response Status: ${response.statusCode}');
      _logResponse(response);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['data'] != null) {
          return Topic.fromJson(jsonData['data']);
        } else if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('id')) {
          return Topic.fromJson(jsonData);
        } else if (jsonData['topics'] != null &&
            jsonData['topics'] is List &&
            jsonData['topics'].isNotEmpty) {
          return Topic.fromJson(jsonData['topics'][0]);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error fetching news by id: $e');
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

      final uri = Uri.parse(NewsApiConfig.newsSearchUrl).replace(
        queryParameters: {
          'search': keyword.trim(),
          if (limit != null) 'limit': limit.toString(),
          if (page != null) 'page': page.toString(),
        },
      );

      print('🔍 Searching news with URL: $uri');

      final response = await http
          .get(uri, headers: _getHeaders())
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
      return 'ไม่สามารถเชื่อมต่อกับอินเทอร์เน็ตได้';
    } else if (error is HttpException) {
      return 'เซิร์ฟเวอร์ไม่สามารถตอบสนองได้';
    } else if (error is FormatException) {
      return 'ข้อมูลที่ได้รับไม่ถูกต้อง';
    } else if (error.toString().contains('TimeoutException')) {
      return 'หมดเวลาในการเชื่อมต่อ';
    }
    return 'เกิดข้อผิดพลาดที่ไม่คาดคิด: ${error.toString()}';
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
}
