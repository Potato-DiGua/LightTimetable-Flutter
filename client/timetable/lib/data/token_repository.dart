import 'package:light_timetable_flutter_app/utils/shared_preferences_util.dart';

class TokenRepository {
  TokenRepository._privateConstructor();

  static final TokenRepository _instance =
      TokenRepository._privateConstructor();

  static TokenRepository getInstance() => _instance;

  String? _token;

  String? get token => _token;

  set token(String? value) {
    _token = value;
    SharedPreferencesUtil.savePreference(
        SharedPreferencesKey.TOKEN, value ?? "");
  }

  Future<String> getTokenFromSharedPreferences() async {
    _token = await SharedPreferencesUtil.getPreference(
        SharedPreferencesKey.TOKEN, "");
    return _token!;
  }

  void clear() {
    _token = "";
    SharedPreferencesUtil.remove(SharedPreferencesKey.TOKEN);
  }
}
