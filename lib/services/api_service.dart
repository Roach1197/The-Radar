import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = "http://localhost:5050"});

  Future<Map<String, dynamic>> generateFullReport(Map<String, dynamic> formData) async {
    final uri = Uri.parse("$baseUrl/ebay-listing");
    final request = http.MultipartRequest("POST", uri);

    formData.forEach((key, value) {
      if (value is bool) {
        request.fields[key] = value ? "on" : "off";
      } else {
        request.fields[key] = value.toString();
      }
    });

    try {
      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        return _extractResultJson(response.body);
      } else {
        throw Exception("Failed to generate full report: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error during /ebay-listing: $e");
    }
  }

  Future<Map<String, dynamic>> calculatePreview(Map<String, dynamic> formData) async {
    final uri = Uri.parse("$baseUrl/ebay-calculate");
    final request = http.MultipartRequest("POST", uri);

    formData.forEach((key, value) {
      if (value is bool) {
        request.fields[key] = value ? "on" : "off";
      } else {
        request.fields[key] = value.toString();
      }
    });

    try {
      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        return _extractResultJson(response.body);
      } else {
        throw Exception("Failed to calculate preview: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error during /ebay-calculate: $e");
    }
  }

  Map<String, dynamic> _extractResultJson(String html) {
    final jsonStart = html.indexOf("window.reportData = ");
    if (jsonStart == -1) throw Exception("No report JSON found in HTML response.");
    final start = jsonStart + "window.reportData = ".length;
    final end = html.indexOf(";</script>", start);
    if (end == -1) throw Exception("JSON end marker not found.");
    final rawJson = html.substring(start, end).trim();
    return json.decode(rawJson) as Map<String, dynamic>;
  }
}
