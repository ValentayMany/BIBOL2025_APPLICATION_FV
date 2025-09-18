// test/simple_connection_test.dart
// วางไฟล์นี้ใน lib/test/ หรือในไฟล์ main.dart เพื่อทดสอบ

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class SimpleConnectionTest extends StatefulWidget {
  @override
  _SimpleConnectionTestState createState() => _SimpleConnectionTestState();
}

class _SimpleConnectionTestState extends State<SimpleConnectionTest> {
  String _result = 'พร้อมทดสอบ...';
  bool _isLoading = false;

  // Test 1: Basic HTTP request
  Future<void> _testBasicHttp() async {
    setState(() {
      _isLoading = true;
      _result = 'กำลังทดสอบ HTTP request...';
    });

    try {
      print('🔍 Testing basic HTTP...');

      final response = await http
          .get(
            Uri.parse('https://web2025.bibol.edu.la/api/v1/banners/1'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'Flutter Test App/1.0',
            },
          )
          .timeout(Duration(seconds: 15));

      print('📡 Response received: ${response.statusCode}');
      print('📄 Body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _result =
              'SUCCESS!\n'
              'Status: ${response.statusCode}\n'
              'Body length: ${response.body.length}\n'
              'Type: ${data['type']}\n'
              'Banner count: ${data['banners_count']}\n'
              'Message: ${data['msg']}';
        });

        print('✅ Test successful!');
      } else {
        setState(() {
          _result =
              'HTTP Error!\n'
              'Status: ${response.statusCode}\n'
              'Reason: ${response.reasonPhrase}\n'
              'Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...';
        });
      }
    } on SocketException catch (e) {
      print('❌ SocketException: ${e.message}');
      setState(() {
        _result =
            'Network Error (SocketException):\n'
            'Message: ${e.message}\n'
            'Address: ${e.address}\n'
            'Port: ${e.port}\n\n'
            'This usually means:\n'
            '- No internet connection\n'
            '- Server is blocking the request\n'
            '- Network configuration issue';
      });
    } on HttpException catch (e) {
      print('❌ HttpException: ${e.message}');
      setState(() {
        _result = 'HTTP Error:\n${e.message}';
      });
    } on FormatException catch (e) {
      print('❌ FormatException: $e');
      setState(() {
        _result = 'JSON Format Error:\n$e';
      });
    } catch (e) {
      print('❌ Unexpected error: $e');
      setState(() {
        _result = 'Unexpected Error:\n$e';
      });
    }

    setState(() => _isLoading = false);
  }

  // Test 2: Test different URLs
  Future<void> _testMultipleUrls() async {
    setState(() {
      _isLoading = true;
      _result = 'กำลังทดสอบ URLs หลายอัน...';
    });

    final urls = [
      'https://web2025.bibol.edu.la',
      'https://web2025.bibol.edu.la/api',
      'https://web2025.bibol.edu.la/api/v1',
      'https://web2025.bibol.edu.la/api/v1/banners',
      'https://web2025.bibol.edu.la/api/v1/banners/1',
    ];

    String result = 'URL Test Results:\n\n';

    for (int i = 0; i < urls.length; i++) {
      try {
        print('🔍 Testing ${i + 1}/${urls.length}: ${urls[i]}');

        final response = await http
            .get(Uri.parse(urls[i]))
            .timeout(Duration(seconds: 8));

        result +=
            '${i + 1}. ${urls[i]}\n'
            '   Status: ${response.statusCode} ✅\n'
            '   Size: ${response.body.length} bytes\n\n';

        print('✅ ${urls[i]} -> ${response.statusCode}');
      } catch (e) {
        result +=
            '${i + 1}. ${urls[i]}\n'
            '   Error: ${e.toString().substring(0, 50)}... ❌\n\n';
        print('❌ ${urls[i]} -> Error: $e');
      }
    }

    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  // Test 3: Check network connectivity
  Future<void> _testNetworkInfo() async {
    setState(() {
      _isLoading = true;
      _result = 'กำลังตรวจสอบเครือข่าย...';
    });

    String info = 'Network Information:\n\n';

    try {
      // Test Google (reliable endpoint)
      print('🔍 Testing Google connectivity...');
      final googleResponse = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 5));
      info += 'Google.com: ${googleResponse.statusCode} ✅\n';
    } catch (e) {
      info += 'Google.com: Error ❌\n';
      print('❌ Google test failed: $e');
    }

    try {
      // Test JSONPlaceholder (another reliable API)
      print('🔍 Testing JSONPlaceholder...');
      final jsonResponse = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
          .timeout(Duration(seconds: 5));
      info += 'JSONPlaceholder: ${jsonResponse.statusCode} ✅\n';
    } catch (e) {
      info += 'JSONPlaceholder: Error ❌\n';
      print('❌ JSONPlaceholder test failed: $e');
    }

    info += '\n';

    // Test target server
    try {
      print('🔍 Testing target server...');
      final targetResponse = await http
          .get(Uri.parse('https://web2025.bibol.edu.la'))
          .timeout(Duration(seconds: 10));
      info += 'Target Server: ${targetResponse.statusCode} ✅\n';
    } catch (e) {
      info += 'Target Server: Error ❌\n';
      info += 'Error details: ${e.toString()}\n';
      print('❌ Target server test failed: $e');
    }

    setState(() {
      _result = info;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connection Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isLoading)
              LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            SizedBox(height: 16),

            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testBasicHttp,
                    child: Text('Test API'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testMultipleUrls,
                    child: Text('Test URLs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            ElevatedButton(
              onPressed: _isLoading ? null : _testNetworkInfo,
              child: Text('Check Network'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 40),
              ),
            ),

            SizedBox(height: 16),

            // Results
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            Text(
              'Note: ดูผลลัพธ์ใน Debug Console ด้วย',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// เพื่อใช้ในการทดสอบ เพิ่มใน main.dart:
/*
void main() {
  runApp(MaterialApp(
    home: SimpleConnectionTest(),
    debugShowCheckedModeBanner: false,
  ));
}
*/
