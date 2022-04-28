import 'dart:io' show Directory, Platform;

import 'package:path_provider/path_provider.dart';

class PathProvider {
  static Future<String> getPath() async {
    String? externalStorageDirPath = '';
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      externalStorageDirPath = directory?.path;
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }

    /// Use other directory to avoid deleting db file.
    String path = externalStorageDirPath! + '/files';

    if (!Directory(path).existsSync()) {
      await Directory(path).create();
    }
    return path;
  }
}