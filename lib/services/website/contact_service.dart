// lib/services/website/contact_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:BIBOL/models/website/website_info_model.dart';
import 'package:BIBOL/models/website/contact_model.dart';
import 'package:BIBOL/config/bibol_api.dart';
import 'package:http/http.dart' as http;

class ContactService {
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

  /// Get contacts information from the API
  static Future<List<ContactModel>> getContacts() async {
    try {
      final response = await http.get(
        Uri.parse(WebsiteApiConfig.contactsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // ✅ Handle the actual API response structure
        if (jsonData is Map && jsonData['details'] is Map) {
          // API returns single contact in 'details' field
          final contactDetails = jsonData['details'];
          print('✅ Parsing contact details: $contactDetails');

          final contact = ContactModel.fromJson(contactDetails);
          print('✅ Successfully parsed contact: ${contact.displayName}');
          print('   - Phone: ${contact.phone}');
          print('   - Mobile: ${contact.mobile}');
          print('   - Has Phone: ${contact.hasPhone}');
          print('   - Formatted Phone: ${contact.formattedPhone}');

          return [contact];
        } else if (jsonData is List) {
          // Handle if API returns array of contacts
          print('✅ Parsing contacts array');
          final contacts =
              jsonData
                  .map((contactJson) => ContactModel.fromJson(contactJson))
                  .toList();
          return contacts;
        } else if (jsonData['data'] is List) {
          // Handle if API returns contacts in data field
          print('✅ Parsing contacts from data field');
          final contacts =
              (jsonData['data'] as List)
                  .map((contactJson) => ContactModel.fromJson(contactJson))
                  .toList();
          return contacts;
        } else {
          print('❌ Unexpected response structure for contacts');
          print(
            'Available keys: ${jsonData is Map ? jsonData.keys.toList() : 'Not a Map'}',
          );

          // Return fallback data
          return _getFallbackContact();
        }
      } else {
        print('❌ Failed to load contacts: ${response.statusCode}');
        print('Response body: ${response.body}');

        // Return fallback data
        return _getFallbackContact();
      }
    } catch (e) {
      print('❌ Error fetching contacts: $e');

      // Return fallback data
      return _getFallbackContact();
    }
  }

  /// Get fallback contact data
  static List<ContactModel> _getFallbackContact() {
    print('🔄 Using fallback contact data');
    return [
      ContactModel(
        name: 'BIBOL Institute',
        phone: '(+856-21) 770 916',
        mobile: '(+856-21) 770 916',
        fax: '(+856-21) 770967',
        email: 'bankinginstitute@bibol.edu.la',
        address: 'ບ້ານ ຕານມີໄຊ, ເມືອງ ໄຊທານີ, ນະຄອນຫຼວງວຽງຈັນ',
        workingTime: 'ວັນຈັນ - ວັນສຸກ 8:00 - 16:00',
      ),
    ];
  }

  /// Get a single contact by ID
  static Future<ContactModel?> getContactById(String contactId) async {
    try {
      final response = await http.get(
        Uri.parse('${WebsiteApiConfig.contactsUrl}/$contactId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Handle different response structures
        Map<String, dynamic> contactData;
        if (jsonData is Map<String, dynamic>) {
          contactData = jsonData;
        } else if (jsonData['data'] is Map<String, dynamic>) {
          contactData = jsonData['data'];
        } else if (jsonData['contact'] is Map<String, dynamic>) {
          contactData = jsonData['contact'];
        } else if (jsonData['details'] is Map<String, dynamic>) {
          contactData = jsonData['details'];
        } else {
          print('❌ Unexpected response structure for contact');
          return null;
        }

        return ContactModel.fromJson(contactData);
      } else {
        print('❌ Failed to load contact: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching contact: $e');
    }

    return null;
  }
}
