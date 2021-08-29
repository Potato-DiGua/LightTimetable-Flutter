import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/utils/text_util.dart';

class UserProvider extends ChangeNotifier {
  String _name = "";
  bool isLogin = false;
  String _userIcon = "";

  String get userIcon => _userIcon;

  set userIcon(String? value) {
    _userIcon = TextUtil.isEmptyOrDefault(value, "");
    notifyListeners();
  }

  void updateName(String? name) {
    _name = name ?? "";
    notifyListeners();
  }

  void updateLoginState(bool? isLogin, String? name, String? userIcon) {
    _name = name ?? "";
    this.isLogin = isLogin ?? false;
    _userIcon = userIcon ?? "";
    notifyListeners();
  }

  String get name => _name;
}
