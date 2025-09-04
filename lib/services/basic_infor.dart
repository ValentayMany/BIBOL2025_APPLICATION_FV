import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class InforService {
  // สำหรับ Chrome / Desktop ผ่าน ngrok
  static const String _localHost =
      "https://632b91295535.ngrok-free.app/api/information/news";

  // สำหรับมือถือจริง (ผ่าน USB + adb reverse)
  static const String _mobileHost =
      "http://localhost:8000/api/information/news"; // <-- เปลี่ยนตรงนี้

  // เลือก host ตาม platform
  static String get baseUrl {
    if (Platform.isAndroid || Platform.isIOS) {
      return _mobileHost;
    } else {
      return _localHost;
    }
  }

  // Fetch news by ID
  static Future<Map<String, dynamic>> getNewsById(int id) async {
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load news with ID $id");
    }
  }

  // Fetch all news
  static Future<List<Map<String, dynamic>>> getAllNews() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception("Failed to load news");
    }
  }
}
