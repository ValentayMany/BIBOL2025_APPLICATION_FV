import 'dart:convert';
import 'package:http/http.dart' as http;

class InforService {
  static const String baseUrl = "http://localhost:8000/api/information/news";

  static Future<Map<String, dynamic>> getNewsById(int id) async {
    final url = Uri.parse("$baseUrl/$id");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load news");
    }
  }
}
