import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:wazplay/support/utils/path.dart';

class Download {
  static Future<String?> image(String url, {String? fileName}) async {
    var path = await PathProvider.getPath();
    if (fileName == null) {
      var splits = url.split('/');
      fileName = splits[splits.length - 1];
    }
    var filePath = '$path/$fileName';
    var file = File(filePath);
    if (file.existsSync()) {
      return null;
    }
    Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }
    final response = await http.get(uri);
    if (response.contentLength == 0) {
      return null;
    }
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
