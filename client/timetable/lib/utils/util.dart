
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:light_timetable_flutter_app/utils/device_type.dart';
import 'package:light_timetable_flutter_app/utils/text_util.dart';
import 'package:provider/provider.dart';

class Util {
  Util._();

  /// 值[1,7]，1为周一
  static int getDayOfWeek() {
    return DateTime.now().weekday;
  }

  static String getDayOfWeekString(int? week) {
    if (week == null || week < 1 || week > 7) {
      return "";
    }
    return ["周一", "周二", "周三", "周四", "周五", "周六", "周日"][week - 1];
  }

  static void showToast(String? msg) {
    if (TextUtil.isEmpty(msg)) {
      return;
    }
    Fluttertoast.showToast(
        msg: msg!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black87,
        fontSize: 16.0);
  }

  static void cancelFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static const _WEEK_OPTIONS = <String>["周", "单周", "双周"];

  static String getFormatStringFromWeekOfTerm(int weekOfTerm, int maxWeekNum) {
    if (!isWeekOfTermValid(weekOfTerm, maxWeekNum)) {
      return "请选择周数";
    }
    return getStringFromWeekOfTerm(weekOfTerm, maxWeekNum) +
        " [" +
        _WEEK_OPTIONS[getWeekOptionFromWeekOfTerm(weekOfTerm, maxWeekNum)] +
        "]";
  }

  static const _SINGLE_DOUBLE_WEEK = 0;
  static const _SINGLE_WEEK = 1;
  static const _DOUBLE_WEEK = 2;

  static String getStringFromWeekOfTerm(int weekOfTerm, int maxWeekNum) {
    if (weekOfTerm == 0) {
      return "";
    }

    final stringBuilder = StringBuffer();
    final weekOptions = getWeekOptionFromWeekOfTerm(weekOfTerm, maxWeekNum);

    var start = 1;
    var space = 2;
    switch (weekOptions) {
      case _SINGLE_DOUBLE_WEEK:
        space = 1;
        break;
      case _SINGLE_WEEK:
        break;
      case _DOUBLE_WEEK:
        start = 2;
        break;
      default:
        return "error";
    }

    var count = 0;
    for (var i = start; i <= maxWeekNum; i += space) {
      if (Util.courseIsThisWeek(weekOfTerm, i, maxWeekNum)) {
        if (count == 0) {
          stringBuilder.write(i);
        }
        count += 1;
      } else {
        if (count == 1) {
          stringBuilder.write(',');
        } else if (count > 1) {
          stringBuilder.write("-${i - space},");
        }
        count = 0;
      }
    }
    if (count > 1) {
      stringBuilder.write('-');
      var max = maxWeekNum;
      if (start == 1 && max % 2 == 0) {
        //单周
        max--;
      } else if (start == 2 && max % 2 == 1) {
        //双周
        max--;
      }
      stringBuilder.write(max);
    }

    final result = stringBuilder.toString();

    if (result.endsWith(",")) {
      return result.substring(0, result.length - 1);
    } else {
      return stringBuilder.toString();
    }
  }

  static int getWeekOptionFromWeekOfTerm(int weekOfTerm, int maxWeekNum) {
    int singleWeek = 0x55555555;
    int doubleWeek = ~singleWeek;
    if (maxWeekNum % 2 == 0) {
      int temp = singleWeek;
      singleWeek = doubleWeek;
      doubleWeek = temp;
    }

    bool hasSingleWeek = (singleWeek & weekOfTerm) != 0;
    bool hasDoubleWeek = (doubleWeek & weekOfTerm) != 0;
    return hasSingleWeek && hasDoubleWeek
        ? 0
        : (hasSingleWeek ? 1 : (hasDoubleWeek ? 2 : -1));
  }

  static bool isWeekOfTermValid(int? weekOfTerm, int maxWeekNum) {
    if (weekOfTerm == null) {
      return false;
    } else {
      return ((1 << maxWeekNum) - 1) & weekOfTerm != 0;
    }
  }

  static T getReadProvider<T>(BuildContext context) {
    return Provider.of<T>(context, listen: false);
  }

  static bool courseIsThisWeek(
      int weekOfTerm, int currentWeek, int maxWeekNum) {
    return (weekOfTerm >> (maxWeekNum - currentWeek) & 0x01) == 1;
  }

  /// 获取本周一的开始时间（00:00:00）
  static DateTime getMondayTime() {
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(
        (DateTime.now().millisecondsSinceEpoch ~/ (1000 * 1000)) * 1000 * 1000);
    return now.subtract(
        Duration(days: now.weekday - 1, hours: now.hour, minutes: now.minute));
  }

  /// 1970年1月5日（周一）至今的周数
  static int getWeekSinceEpoch() {
    final DateTime now = DateTime.now();
    final daySince = now.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24) - 4;
    return daySince ~/ 7;
  }

  /// 当为桌面环境时使用资源中的字体
  static String? getDesktopFontFamily() {
    return DeviceType.isMobile ? null : "NotoSansSC";
  }

  /// 返回单位为秒的时间戳
  static int getTimeStamp() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}
