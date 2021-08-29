import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtil {
  FileUtil._();

  static Future<String> getApplicationDocumentPath() async {
    return (await getApplicationDocumentsDirectory()).path;
  }

  static Future<String> getTempDirPath() {
    return getTemporaryDirectory().then((value) => value.path);
  }

  static Future<bool> copy(String source, String dest) async {
    try {
      File sourceFile = File(source);
      if (!sourceFile.existsSync()) {
        return false;
      }
      await sourceFile.copy(dest);
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future<bool> saveAsJson(String fileName, String json) async {
    try {
      final directory = (await getApplicationDocumentsDirectory()).path;
      final path = "$directory/json/$fileName";
      File file = File(path);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
      await file.writeAsString(json);
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future<String> readFromJson(String fileName) async {
    try {
      final directory = (await getApplicationDocumentsDirectory()).path;
      final path = "$directory/json/$fileName";
      File file = File(path);
      if (!file.existsSync()) {
        return "";
      }
      return (await file.readAsString());
    } catch (e) {
      print(e);
    }
    return "";
  }

  ///获取文件扩展名
  static String getExtensionFromPath(String path) {
    int index = path.lastIndexOf('.');
    if (index == -1) {
      return "";
    } else {
      return path.substring(index + 1);
    }
  }

  static bool delete(String? path) {
    if (path == null) return true;
    try {
      File file = File(path);
      if (!file.existsSync()) {
        return true;
      }
      file.deleteSync();
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }
}
