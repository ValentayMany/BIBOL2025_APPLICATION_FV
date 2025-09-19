// services/Banner_service.dart
import 'dart:convert';
import 'dart:io';

import '../models/banner_models.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/banner_response.dart';
import '../config/banner_api_config.dart';

class BannerService {
  static const Duration _defaultTimeout = Duration(seconds: 15);
  static const int _maxRetries = 2; // ลดจำนวน retry

  /// Fetch all banners from API with enhanced error handling
  static Future<ApiResponse<List<BannerModel>>> fetchBanners({
    int? limit,
  }) async {
    int retries = 0;

    while (retries < _maxRetries) {
      try {
        final url = BannerApiConfig.getBannersUrl(limit: limit);
        debugPrint('🔍 Fetching banners from: $url (attempt ${retries + 1})');

        // Create HTTP client with custom settings
        final client = http.Client();

        try {
          final response = await client
              .get(Uri.parse(url), headers: _getHeaders())
              .timeout(_defaultTimeout);

          debugPrint('📡 Banner API Response Status: ${response.statusCode}');
          _logResponse(response);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            // Use BannerListResponse for structured handling
            final bannerResponse = BannerListResponse.fromJson(data);

            if (bannerResponse.isSuccess && bannerResponse.hasData) {
              debugPrint(
                '✅ Successfully loaded ${bannerResponse.banners.length} banners',
              );
              return ApiResponse.success(
                bannerResponse.banners.cast<BannerModel>(),
                message: bannerResponse.msg,
              );
            } else {
              return ApiResponse.error(
                bannerResponse.msg.isEmpty
                    ? 'ไม่มีข้อมูลแบนเนอร์'
                    : bannerResponse.msg,
                statusCode: response.statusCode,
              );
            }
          } else if (response.statusCode >= 500 && retries < _maxRetries - 1) {
            retries++;
            await Future.delayed(Duration(seconds: retries * 2));
            continue;
          } else {
            return ApiResponse.error(
              'HTTP ${response.statusCode}: ${response.reasonPhrase}',
              statusCode: response.statusCode,
            );
          }
        } finally {
          client.close(); // ปิด client เพื่อป้องกัน connection leaks
        }
      } on SocketException catch (e) {
        debugPrint('❌ SocketException (attempt ${retries + 1}): ${e.message}');

        if (retries == _maxRetries - 1) {
          return ApiResponse.error(
            'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้\nกรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต',
          );
        }
      } on HttpException catch (e) {
        debugPrint('❌ HttpException (attempt ${retries + 1}): ${e.message}');

        if (retries == _maxRetries - 1) {
          return ApiResponse.error(
            'เซิร์ฟเวอร์ไม่สามารถตอบสนองได้: ${e.message}',
          );
        }
      } on FormatException catch (e) {
        debugPrint('❌ FormatException (attempt ${retries + 1}): $e');
        return ApiResponse.error('ข้อมูลที่ได้รับไม่ถูกต้อง');
      } catch (e) {
        debugPrint('❌ Unexpected error (attempt ${retries + 1}): $e');

        if (e.toString().contains('TimeoutException') ||
            e.toString().contains('timeout')) {
          if (retries == _maxRetries - 1) {
            return ApiResponse.error(
              'หมดเวลาในการเชื่อมต่อ กรุณาลองใหม่อีกครั้ง',
            );
          }
        } else if (retries == _maxRetries - 1) {
          return ApiResponse.error(_getErrorMessage(e));
        }
      }

      retries++;
      if (retries < _maxRetries) {
        await Future.delayed(Duration(seconds: retries));
      }
    }

    return ApiResponse.error(
      'ไม่สามารถโหลดแบนเนอร์ได้หลังจากพยายาม $_maxRetries ครั้ง',
    );
  }

  /// Test API connection with detailed diagnostics
  static Future<Map<String, dynamic>> diagnosticTest() async {
    final result = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <String, dynamic>{},
    };

    debugPrint('🔧 Starting diagnostic test...');

    // Test 1: Basic connectivity
    try {
      final client = http.Client();
      final response = await client
          .get(Uri.parse('https://web2025.bibol.edu.la'))
          .timeout(Duration(seconds: 5));

      result['tests']['basic_connectivity'] = {
        'success': response.statusCode == 200,
        'status_code': response.statusCode,
        'response_time': '< 5s',
      };
      client.close();
    } catch (e) {
      result['tests']['basic_connectivity'] = {
        'success': false,
        'error': e.toString(),
      };
    }

    // Test 2: API endpoint
    try {
      final client = http.Client();
      final url = BannerApiConfig.getBannersUrl();
      final response = await client
          .get(Uri.parse(url), headers: _getHeaders())
          .timeout(Duration(seconds: 10));

      result['tests']['api_endpoint'] = {
        'success': response.statusCode == 200,
        'status_code': response.statusCode,
        'url': url,
        'response_size': response.body.length,
      };
      client.close();
    } catch (e) {
      result['tests']['api_endpoint'] = {
        'success': false,
        'error': e.toString(),
        'url': BannerApiConfig.getBannersUrl(),
      };
    }

    // Test 3: JSON parsing
    try {
      final response = await fetchBanners();
      result['tests']['data_parsing'] = {
        'success': response.success,
        'banner_count': response.data?.length ?? 0,
        'message': response.message,
      };
    } catch (e) {
      result['tests']['data_parsing'] = {
        'success': false,
        'error': e.toString(),
      };
    }

    debugPrint('🔧 Diagnostic complete: ${result.toString()}');
    return result;
  }

  /// Simple connection test
  static Future<bool> testConnection() async {
    try {
      final client = http.Client();

      try {
        final response = await client
            .get(
              Uri.parse(BannerApiConfig.getBannersUrl()),
              headers: _getHeaders(),
            )
            .timeout(const Duration(seconds: 8));

        debugPrint('📡 Connection test result: ${response.statusCode}');
        return response.statusCode == 200;
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('❌ Connection test error: $e');
      return false;
    }
  }

  /// Legacy methods for backward compatibility
  static Future<List<BannerModel>> fetchBannersLegacy({int? limit}) async {
    final response = await fetchBanners(limit: limit);
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  // Helper methods
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Flutter App/1.0',
      'Cache-Control': 'no-cache',
      'Connection': 'close', // Force close connection
    };
  }

  static void _logResponse(http.Response response) {
    if (kDebugMode) {
      final bodyPreview =
          response.body.length > 300
              ? response.body.substring(0, 300) + '...'
              : response.body;
      debugPrint('📄 Response Body: $bodyPreview');
    }
  }

  static String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (error is SocketException) {
      if (errorStr.contains('connection refused')) {
        return 'เซิร์ฟเวอร์ปฏิเสธการเชื่อมต่อ กรุณาตรวจสอบ URL หรือลองใหม่อีกครั้ง';
      }
      return 'ไม่สามารถเชื่อมต่อกับอินเทอร์เน็ตได้';
    } else if (error is HttpException) {
      return 'เซิร์ฟเวอร์ไม่สามารถตอบสนองได้';
    } else if (error is FormatException) {
      return 'ข้อมูลที่ได้รับไม่ถูกต้อง';
    } else if (errorStr.contains('timeout')) {
      return 'หมดเวลาในการเชื่อมต่อ';
    }

    return 'เกิดข้อผิดพลาด: ${error.toString()}';
  }

  /// Fetch single banner by ID
  static Future<ApiResponse<BannerModel>> fetchBannerById(int id) async {
    int retries = 0;

    while (retries < _maxRetries) {
      try {
        final url = BannerApiConfig.getBannerByIdUrl(id);
        debugPrint(
          '🔍 Fetching banner by ID from: $url (attempt ${retries + 1})',
        );

        final client = http.Client();

        try {
          final response = await client
              .get(Uri.parse(url), headers: _getHeaders())
              .timeout(_defaultTimeout);

          debugPrint(
            '📡 Banner by ID API Response Status: ${response.statusCode}',
          );
          _logResponse(response);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            // Use BannerDetailResponse for structured handling
            final bannerResponse = BannerDetailResponse.fromJson(data);

            if (bannerResponse.isSuccess && bannerResponse.hasData) {
              return ApiResponse.success(
                bannerResponse.banner! as BannerModel,
                message: bannerResponse.msg,
              );
            } else {
              return ApiResponse.error(
                bannerResponse.msg.isEmpty
                    ? 'ไม่พบแบนเนอร์ที่ต้องการ'
                    : bannerResponse.msg,
                statusCode: response.statusCode,
              );
            }
          } else if (response.statusCode == 404) {
            debugPrint('⚠️ Banner with ID $id not found');
            return ApiResponse.error(
              'ไม่พบแบนเนอร์ที่มี ID: $id',
              statusCode: 404,
            );
          } else if (response.statusCode >= 500 && retries < _maxRetries - 1) {
            retries++;
            await Future.delayed(Duration(seconds: retries * 2));
            continue;
          } else {
            return ApiResponse.error(
              'HTTP ${response.statusCode}: ${response.reasonPhrase}',
              statusCode: response.statusCode,
            );
          }
        } finally {
          client.close();
        }
      } catch (e) {
        debugPrint(
          '❌ Error fetching banner by id (attempt ${retries + 1}): $e',
        );

        if (retries == _maxRetries - 1) {
          return ApiResponse.error(_getErrorMessage(e));
        }

        retries++;
        await Future.delayed(Duration(seconds: retries));
      }
    }

    return ApiResponse.error(
      'ไม่สามารถโหลดแบนเนอร์ได้หลังจากพยายาม $_maxRetries ครั้ง',
    );
  }

  static Future<ApiResponse<List<BannerModel>>> fetchActiveBanners({
    int? limit,
  }) async {
    final response = await fetchBanners(limit: limit);
    if (response.success && response.data != null) {
      final activeBanners =
          response.data!.where((banner) => banner.isActive).toList();
      return ApiResponse.success(activeBanners);
    }
    return response;
  }

  static String getProcessedImageUrl(String originalUrl) {
    if (originalUrl.isEmpty) return '';
    return BannerApiConfig.getImageUrl(originalUrl);
  }

  static Future<int> getBannersCount() async {
    final response = await fetchBanners();
    return response.success && response.data != null
        ? response.data!.length
        : 0;
  }

  static void debugApiConfig() {
    BannerApiConfig.printConfig();
  }

  static refreshBanners() {}
}
