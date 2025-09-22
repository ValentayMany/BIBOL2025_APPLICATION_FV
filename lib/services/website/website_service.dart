import 'dart:convert';
import 'package:BIBOL/models/website/website_info_model.dart';
import 'package:http/http.dart' as http;

class WebsiteService {
  static Future<WebsiteInfoModel?> getWebsiteInfo() async {
    const String url = 'https://web2025.bibol.edu.la/api/v1/website/info';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WebsiteInfoModel.fromJson(jsonData['details']);
      } else {
        print('❌ Failed to load website info: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching website info: $e');
    }

    return null;
  }
}
