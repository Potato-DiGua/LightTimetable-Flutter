import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/components/pickerview/picker_view.dart';
import 'package:light_timetable_flutter_app/components/pickerview/picker_view_popup.dart';
import 'package:light_timetable_flutter_app/model/course.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';
import 'package:light_timetable_flutter_app/ui/editcourse/select_week_of_term.dart';
import 'package:light_timetable_flutter_app/utils/dialog_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';

class EditCoursePage extends StatefulWidget {
  final int index;

  /// 是否为添加课程
  final bool isAppended;

  EditCoursePage({required this.index, required this.isAppended, Key? key})
      : super(key: key);

  @override
  _EditCoursePageState createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  late final Course course;

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _teacherController;

  @override
  void initState() {
    super.initState();

    course = widget.isAppended
        ? Course()
        : Store.getInstanceReadMode(context).courses[widget.index].clone();

    _nameController = TextEditingController(text: course.name);

    _locationController = TextEditingController(text: course.classRoom);

    _teacherController = TextEditingController(text: course.teacher);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text("编辑"),
        actions: [
          if (!widget.isAppended)
            IconButton(
                splashRadius: 16,
                padding: const EdgeInsets.all(5),
                icon: Icon(
                  Icons.delete,
                  size: 24,
                ),
                tooltip: "删除",
                onPressed: _deleteAction),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.all(5),
              icon: Icon(
                Icons.save,
                size: 24,
              ),
              tooltip: "保存",
              onPressed: _saveAction)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      Text(
                        "课程: ",
                        style: const TextStyle(fontSize: 18),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "请填写课程名",
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),
                      )
                    ],
                  ),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              "教室: ",
                              style: const TextStyle(fontSize: 18),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _locationController,
                                decoration: InputDecoration(
                                  hintText: "可不填",
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: 18),
                              ),
                            )
                          ],
                        ),
                        InkWell(
                          onTap: _selectWeekOfTerm,
                          child: Container(
                            height: 48,
                            child: Row(
                              children: [
                                Text(
                                  "周数: ",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  Util.getFormatStringFromWeekOfTerm(
                                      course.weekOfTerm,
                                      Store.getInstanceReadMode(context)
                                          .maxWeekNum),
                                  style: const TextStyle(fontSize: 18),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _selectClassIndex,
                          child: Container(
                            height: 48,
                            child: Row(
                              children: [
                                Text(
                                  "节数: ",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  _getClassIndexString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "老师: ",
                              style: const TextStyle(fontSize: 18),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _teacherController,
                                decoration: InputDecoration(
                                  hintText: "可不填",
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: 18),
                              ),
                            )
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAction() {
    Util.cancelFocus(context);
    _saveInput();
    final Store store = Store.getInstanceReadMode(context);

    if (course.classLength == 0 ||
        course.name.trim().isEmpty ||
        !Util.isWeekOfTermValid(course.weekOfTerm, store.maxWeekNum)) {
      DialogUtil.showTipDialog(context, "请填写课程名、上课时间、上课周数");
      return;
    }

    DialogUtil.showConfirmDialog(context, "您确定要保存该课程吗", () {
      final List<Course> courses = List.from(store.courses);
      if (!widget.isAppended) {
        courses.removeAt(widget.index);
      }
      courses.add(course);
      store.courses = courses;
      Util.showToast("修改课程成功");
      Navigator.of(context).pop();
    });
  }

  void _deleteAction() {
    DialogUtil.showConfirmDialog(context, "您确定要删除${course.name}吗？", () {
      if (Store.getInstanceReadMode(context)
          .deleteCourseByIndex(widget.index)) {
        Util.showToast("删除${course.name}成功");
      } else {
        Util.showToast("删除${course.name}失败");
      }
      Navigator.pop(context);
    });
  }

  String _getClassIndexString() {
    if (course.classLength > 0) {
      return "${Util.getDayOfWeekString(course.dayOfWeek)} ${course.classStart}-${course.classStart + course.classLength - 1}节";
    } else {
      return "请选择节数";
    }
  }

  void _saveInput() {
    course.name = _nameController.text.trim();
    course.teacher = _teacherController.text.trim();
    course.classRoom = _locationController.text.trim();
  }

  void _selectWeekOfTerm() {
    Util.cancelFocus(context);
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SelectWeekOfTerm(
            height: 300,
            weekOfTerm: course.weekOfTerm,
            okBtnOnClick: (states) {
              setState(() {
                int weekOfTerm = 0;
                for (int i = 0; i < states.length; i++) {
                  if (states[i]) {
                    weekOfTerm += (1 << (states.length - 1 - i));
                  }
                }
                course.weekOfTerm = weekOfTerm;
              });
            },
          );
        });
  }

  static const week = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"];

  void _selectClassIndex() {
    Util.cancelFocus(context);

    PickerController pickerController =
        PickerController(count: 3, selectedItems: [
      course.dayOfWeek - 1,
      course.classStart - 1,
      course.classStart + course.classLength - 2
    ]);

    PickerViewPopup.showMode(
        PickerShowMode.BottomSheet, // AlertDialog or BottomSheet
        controller: pickerController,
        context: context,
        title: Text(
          '选择节数',
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
        onConfirm: (controller) {
          // Store.getInstanceReadMode(context)
          //     .updateCurrentWeek(controller.selectedRowAt(section: 0)! + 1);

          setState(() {
            course.dayOfWeek = controller.selectedRowAt(section: 0)! + 1;
            course.classStart = controller.selectedRowAt(section: 1)! + 1;
            course.classLength = controller.selectedRowAt(section: 2)! -
                controller.selectedRowAt(section: 1)! +
                1;
          });
        },
        onSelectRowChanged: (section, row) {
          if (section != 0) {
            final classStart = pickerController.selectedRowAt(section: 1)!;
            final classEnd = pickerController.selectedRowAt(section: 2)!;
            if (classStart > classEnd) {
              pickerController.animateToRow(min(classStart + 1, 11),
                  atSection: 2);
            }
          }
        },
        builder: (context, popup) {
          return Container(
            height: 250,
            child: popup,
          );
        },
        itemExtent: 40,
        numberofRowsAtSection: (section) {
          switch (section) {
            case 0:
              return 7;
            case 1:
              return 12;
            case 2:
              return 12;
            default:
              return 0;
          }
        },
        itemBuilder: (section, row) {
          if (section == 0) {
            return Text(
              week[row],
              style: TextStyle(
                fontSize: 12,
                fontFamily: Util.getDesktopFontFamily(),
              ),
            );
          } else {
            return Text(
              '第${row + 1}节',
              style: TextStyle(
                fontSize: 12,
                fontFamily: Util.getDesktopFontFamily(),
              ),
            );
          }
        });
  }
}
