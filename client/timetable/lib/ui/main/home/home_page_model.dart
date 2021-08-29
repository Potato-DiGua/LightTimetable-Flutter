import 'package:dio/dio.dart';
import 'package:light_timetable_flutter_app/utils/http_util.dart';

class HomePageModel {
  Future<Response<String>> shareTimetable(String timetableJson) {
    return HttpUtil.client.post<String>("/calendar/shareCalendar",
        data: FormData.fromMap({"calendar": timetableJson}));
  }
}
