import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

///pivot download
class PivotXlsxDownloader {
  static Future<File> download({
    required String baseUrl,
    required String sessionId,
    required Map<String, dynamic> pivotData,
  }) async {
    final url = Uri.parse('$baseUrl/web/pivot/export_xlsx');

    final response = await http.post(
      Uri.parse('$baseUrl/web/pivot/export_xlsx'),
      headers: {
        'Cookie': 'session_id=$sessionId',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'data': jsonEncode(pivotData)},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to export XLSX (status ${response.statusCode})');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pivot_report.xlsx');

    await file.writeAsBytes(response.bodyBytes);
    return file;
  }
}
