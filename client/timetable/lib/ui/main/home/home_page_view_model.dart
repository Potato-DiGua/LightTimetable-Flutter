import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:light_timetable_flutter_app/components/color_picker_dialog.dart';
import 'package:light_timetable_flutter_app/data/values.dart';
import 'package:light_timetable_flutter_app/entity/background_config.dart';
import 'package:light_timetable_flutter_app/entity/time.dart';
import 'package:light_timetable_flutter_app/model/course.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';
import 'package:light_timetable_flutter_app/ui/editcourse/edit_course_page.dart';
import 'package:light_timetable_flutter_app/ui/main/home/home_page_model.dart';
import 'package:light_timetable_flutter_app/ui/qrscan/qr_scan.dart';
import 'package:light_timetable_flutter_app/utils/file_util.dart';
import 'package:light_timetable_flutter_app/utils/http_util.dart';
import 'package:light_timetable_flutter_app/utils/shared_preferences_util.dart';
import 'package:light_timetable_flutter_app/utils/text_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef UpdateCallBack = void Function();

class HomePageViewModel extends ChangeNotifier {
  final HomePageModel _model = HomePageModel();
  BackgroundConfig _backgroundConfig =
      BackgroundConfig(type: BackgroundType.defaultBg);

  final Store _store;

  HomePageViewModel(this._store);

  BackgroundConfig get backgroundConfig => _backgroundConfig;
  final picker = ImagePicker();

  void updateBgConfig({BackgroundConfig? value}) {
    if (value != null) {
      _backgroundConfig = value;
    }
    notifyListeners();
    SharedPreferencesUtil.savePreference(
        SharedPreferencesKey.BG_CONFIG, json.encode(backgroundConfig));
  }

  void update(UpdateCallBack updateCallBack) {
    updateCallBack();
    notifyListeners();
  }

  void jumpToCollegeLoginPage(BuildContext context) async {
    final name = await SharedPreferencesUtil.getPreference(
        SharedPreferencesKey.COLLEGE_NAME, "");
    if (TextUtil.isNotEmpty(name)) {
      Navigator.pushNamed(context, "collegeLogin", arguments: {"name": name});
    } else {
      Navigator.pushNamed(context, "selectCollege").then((value) {
        if (value is String && TextUtil.isNotEmpty(value)) {
          Navigator.pushNamed(context, "collegeLogin",
              arguments: {"name": value});
        }
      });
    }
  }

  Future shareTimetable(String timetableJson) async {
    final resp = await _model.shareTimetable(timetableJson);
    final data = HttpUtil.getDataFromResponse(resp.data);
    return data["shareUrl"];
  }

  void jumpToEditCoursePage(BuildContext context, int index, bool isAppended) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditCoursePage(
        index: index,
        isAppended: isAppended,
      );
    }));
  }

  void scanQRCodeAction(BuildContext context) async {
    try {
      final qrData = await Navigator.push<String>(context,
          MaterialPageRoute(builder: (context) {
        return QRCodeScanPage();
      }));
      if (TextUtil.isEmpty(qrData)) {
        return;
      }
      final resp = await HttpUtil.client.get<String>(qrData!);
      final data = await HttpUtil.getDataFromResponse(resp.data);
      List<Course> courses = [];
      if (data is List) {
        for (final item in data) {
          courses.add(Course.fromJson(item));
        }
        _store.courses = courses;
        Util.showToast("导入分享课程表成功");
      }
    } catch (e) {
      print(e);
      Util.showToast("导入分享课程表失败");
    }
  }

  void pickColorAction(BuildContext context) async {
    try {
      final color = await ColorPickerDialog.show(context,
          initColor: backgroundConfig.color == null
              ? Values.bgWhite
              : Color(backgroundConfig.color!));
      if (color != null) {
        backgroundConfig
          ..type = BackgroundType.color
          ..color = color.value;
        updateBgConfig();
      }
    } catch (e) {
      print(e);
    }
  }

  void init() {
    _initCoursesData();
    _initCurrentWeek();
    _initClassTime();

    try {
      SharedPreferencesUtil.getPreference(SharedPreferencesKey.BG_CONFIG, "")
          .then((value) {
        if (value is String && value.trim().isNotEmpty) {
          final map = json.decode(value);
          if (map is Map<String, dynamic>) {
            _backgroundConfig = BackgroundConfig.fromJson(map);
            notifyListeners();
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _initCoursesData() {
    FileUtil.readFromJson(Store.COURSE_JSON_FILE_NAME).then((value) {
      if (value.isEmpty) {
        return;
      }
      final courses = <Course>[];
      final List<dynamic>? list = json.decode(value);
      if (list != null) {
        list.forEach((v) {
          courses.add(new Course.fromJson(v));
        });
      }

      _store.courses = courses;
    }).catchError((error) {
      print(error);
      Util.showToast("从本地读取课程数据失败");
    });
  }

  void _initCurrentWeek() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? currentWeek = prefs.getInt(SharedPreferencesKey.CURRENT_WEEK);
      if (currentWeek != null) {
        currentWeek = Util.getWeekSinceEpoch() - currentWeek;
      }
      _store.updateCurrentWeek(currentWeek ?? 1);
    } catch (e) {
      print(e);
      Util.showToast("读取当前周数失败");
    }
  }

  void _initClassTime() async {
    var times = await SharedPreferencesUtil.getTime();
    if (times.isEmpty) {
      times = [
        TimeEntity(
            start: Time(hour: 8, minute: 0), end: Time(hour: 8, minute: 45)),
        TimeEntity(
            start: Time(hour: 8, minute: 55), end: Time(hour: 9, minute: 40)),
        TimeEntity(
            start: Time(hour: 10, minute: 0), end: Time(hour: 10, minute: 45)),
        TimeEntity(
            start: Time(hour: 10, minute: 55), end: Time(hour: 11, minute: 40)),
        TimeEntity(
            start: Time(hour: 14, minute: 0), end: Time(hour: 14, minute: 45)),
        TimeEntity(
            start: Time(hour: 14, minute: 55), end: Time(hour: 15, minute: 40)),
        TimeEntity(
            start: Time(hour: 16, minute: 0), end: Time(hour: 16, minute: 45)),
        TimeEntity(
            start: Time(hour: 16, minute: 55), end: Time(hour: 17, minute: 40)),
        TimeEntity(
            start: Time(hour: 19, minute: 0), end: Time(hour: 19, minute: 45)),
        TimeEntity(
            start: Time(hour: 19, minute: 55), end: Time(hour: 20, minute: 40)),
        TimeEntity(
            start: Time(hour: 21, minute: 00), end: Time(hour: 21, minute: 45)),
        TimeEntity(
            start: Time(hour: 21, minute: 55), end: Time(hour: 22, minute: 40))
      ];
    }
    _store.classTime = times;
  }

  /// 从相册中选择背景图片
  void selectBgImgFromPhotoGallery() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        return;
      }
      final extension = FileUtil.getExtensionFromPath(pickedFile.path);
      final dir = await FileUtil.getApplicationDocumentPath();
      final newPath =
          "$dir/bg${new DateTime.now().millisecondsSinceEpoch}.$extension";

      if (await FileUtil.copy(pickedFile.path, newPath)) {
        if (backgroundConfig.imgPath?.trim().isNotEmpty ?? false) {
          final old = File(backgroundConfig.imgPath!);
          if (old.existsSync()) {
            old.delete();
          }
        }
        backgroundConfig
          ..imgPath = newPath
          ..type = BackgroundType.img;
        updateBgConfig();
      } else {
        Util.showToast("设置背景图片失败");
      }
    } catch (e) {
      print(e);
      Util.showToast("设置背景图片失败");
    }
  }
}
