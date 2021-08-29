import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/entity/time.dart';
import 'package:light_timetable_flutter_app/model/course.dart';
import 'package:light_timetable_flutter_app/utils/file_util.dart';
import 'package:light_timetable_flutter_app/utils/shared_preferences_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';
import 'package:provider/provider.dart';

class Store extends ChangeNotifier {
  static const COURSE_JSON_FILE_NAME = "timetable.json";

  // 当前周数
  int currentWeek = 1;

  // 最大周数
  int maxWeekNum = 25;

  // 课程列表
  List<Course>? _courses;

  List<Course> get courses => _courses ?? const [];

  List<TimeEntity> _classTime = [];

  List<TimeEntity> get classTime => _classTime;

  set classTime(List<TimeEntity> list) {
    if (_classTime != list) {
      _classTime = list;
      notifyListeners();
      SharedPreferencesUtil.savePreference(
          SharedPreferencesKey.CLASS_TIME, json.encode(_classTime));
    }
  }

  set courses(List<Course>? courses) {
    if (_courses == courses) {
      return;
    }
    _courses = courses ?? const [];
    _courses!.sort();
    saveCourses();
    notifyListeners();
  }

  void saveCourses() {
    FileUtil.saveAsJson(COURSE_JSON_FILE_NAME, json.encode(courses))
        .then((success) {
      if (!success) {
        Util.showToast("课表保存到本地失败！");
      }
    });
  }

  bool deleteCourseByIndex(int index) {
    if (index >= 0 && index < courses.length) {
      courses.removeAt(index);
      courses = List.from(courses);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool deleteCourseByCourse(Course course) {
    return deleteCourseByIndex(courses.indexOf(course));
  }

  void updateCurrentWeek(int currentWeek) {
    if (this.currentWeek == currentWeek) {
      return;
    }
    this.currentWeek = currentWeek;
    notifyListeners();

    SharedPreferencesUtil.savePreference(SharedPreferencesKey.CURRENT_WEEK,
            Util.getWeekSinceEpoch() - currentWeek)
        .catchError((error) {
      print(error);
      Util.showToast("保存当前周数失败");
    });
  }

  static Store getInstance(BuildContext context, {bool listen = false}) {
    return Provider.of<Store>(context, listen: listen);
  }

  static Store getInstanceReadMode(BuildContext context) {
    return getInstance(context, listen: false);
  }
}
