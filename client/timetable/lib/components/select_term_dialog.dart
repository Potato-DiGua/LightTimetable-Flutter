import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/components/pickerview/picker_view.dart';
import 'package:light_timetable_flutter_app/components/pickerview/picker_view_popup.dart';
import 'package:light_timetable_flutter_app/model/course.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';
import 'package:light_timetable_flutter_app/utils/http_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';

/// 得到学期选项
Future<List<String>> getTermOptionsFormInternet() async {
  final resp = await HttpUtil.client.get<String>("/college/term-options");
  final data = HttpUtil.getDataFromResponse(resp.data);
  if (data is List) {
    return data.cast<String>();
  } else {
    return <String>[];
  }
}

/// 选择学期对话框
Future<bool?> showSelectTermDialog(List<String?>? terms, BuildContext context) {
  if (terms == null || terms.isEmpty) {
    return Future.value(null);
  }
  final List<String> _terms = [];
  for (var term in terms) {
    if (term != null && term.trim().isNotEmpty) {
      _terms.add(term);
    }
  }

  final PickerController pickerController =
      PickerController(count: 1, selectedItems: [0]);

  return PickerViewPopup.showMode<bool>(
      PickerShowMode.BottomSheet, // AlertDialog or BottomSheet
      controller: pickerController,
      context: context,
      title: Text(
        '选择学期',
        style: TextStyle(fontSize: 14),
      ),
      cancel: Text(
        '取消',
        style: TextStyle(color: Colors.grey),
      ),
      confirm: Text(
        '确定',
        style: TextStyle(color: Colors.blue),
      ),
      onConfirm: (controller) async {
        final term = _terms[controller.selectedRowAt(section: 0)!];
        final resp = await HttpUtil.client
            .get<String>("/college/timetable", queryParameters: {"term": term});

        final data = HttpUtil.getDataFromResponse(resp.data);
        final List<Course> courses = [];
        if (data is List) {
          data.forEach((v) {
            courses.add(new Course.fromJson(v));
          });
        }
        Store.getInstanceReadMode(context).courses = courses;
        Util.showToast("导入课程成功");
      },
      builder: (context, popup) {
        return Container(
          height: 250,
          child: popup,
        );
      },
      itemExtent: 40,
      numberofRowsAtSection: (section) {
        return _terms.length;
      },
      itemBuilder: (section, row) {
        return Text(
          _terms[row],
          style: const TextStyle(fontSize: 14),
        );
      });
}
