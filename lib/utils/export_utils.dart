import 'dart:convert';
import 'dart:html' as html;

class ExportUtils {
  static void downloadJson(Map<String, dynamic> data, {String fileName = "report.json"}) {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    _downloadFile(jsonStr, fileName, 'application/json');
  }

  static void downloadCsv(Map<String, dynamic> data, {String fileName = "report.csv"}) {
    final buffer = StringBuffer();
    void writeRow(String key, dynamic value) {
      buffer.writeln('"$key","$value"');
    }

    for (final entry in data.entries) {
      if (entry.value is Map) {
        for (final sub in (entry.value as Map).entries) {
          writeRow("${entry.key}.${sub.key}", sub.value);
        }
      } else {
        writeRow(entry.key, entry.value);
      }
    }

    _downloadFile(buffer.toString(), fileName, 'text/csv');
  }

  static void _downloadFile(String content, String fileName, String mimeType) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
