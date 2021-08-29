import 'dart:convert';

import 'package:light_timetable_flutter_app/entity/time.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  SharedPreferencesUtil._();

  /// 存数据
  static Future<bool> savePreference(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is int) {
      return await prefs.setInt(key, value);
    } else if (value is double) {
      return await prefs.setDouble(key, value);
    } else if (value is bool) {
      return await prefs.setBool(key, value);
    } else if (value is String) {
      return await prefs.setString(key, value);
    } else if (value is List<String>) {
      return await prefs.setStringList(key, value);
    } else {
      throw new Exception("不能得到这种类型");
    }
  }

  /// 取数据
  static Future<dynamic> getPreference(String key, dynamic defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (defaultValue is int) {
      return prefs.getInt(key) ?? defaultValue;
    } else if (defaultValue is double) {
      return prefs.getDouble(key) ?? defaultValue;
    } else if (defaultValue is bool) {
      return prefs.getBool(key) ?? defaultValue;
    } else if (defaultValue is String) {
      return prefs.getString(key) ?? defaultValue;
    } else if (defaultValue is List) {
      return prefs.getStringList(key) ?? defaultValue;
    } else {
      throw new Exception("不能得到这种类型");
    }
  }

  /// 删除指定数据
  static void remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key); //删除指定键
  }

  /// 清空整个缓存
  static void clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear(); //清空缓存
  }

  static Future<List<TimeEntity>> getTime() async {
    final String content =
        await getPreference(SharedPreferencesKey.CLASS_TIME, "");
    if (content.trim().isNotEmpty) {
      final list = json.decode(content);
      if (list is List) {
        return list.map((e) => TimeEntity.fromJson(e)).toList();
      }
    }
    return [];
  }
}

class SharedPreferencesKey {
  SharedPreferencesKey._();

  /// token
  static const TOKEN = "token";

  /// 教务系统账号
  static const COLLEGE_ACCOUNT = "college_account";

  /// 教务系统密码
  static const COLLEGE_PWD = "college_pwd";

  /// 学校名称
  static const COLLEGE_NAME = "college_name";

  /// 是否导入课程
  static const IS_IMPORT_CALENDAR = "isImportCalendar";

  static const CLASS_TIME = "class_time";

  static const BG_CONFIG = "bg_config";

  static const CURRENT_WEEK = "currentWeek";
}
