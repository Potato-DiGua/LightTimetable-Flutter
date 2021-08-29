import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/components/course_block.dart';
import 'package:light_timetable_flutter_app/model/course.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';
import 'package:provider/provider.dart';

import '../../coursedetail/course_detail.dart';

class Timetable extends StatelessWidget {
  final double width;
  final double height;

  /// 课程格子外边距
  final double cellMargin = 1;

  Timetable({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final double tableCellWidth = width / 7.0;
    final double tableCellHeight = height / 12.0;

    return Expanded(
        flex: 1,
        child: Container(
          child: Consumer<Store>(builder: (context, state, child) {
            final List<Widget> courseBlockList = [];
            final List<Course> courses = _selectNeedToShowCourse(
                state.courses, state.currentWeek, state.maxWeekNum);

            for (int i = 0; i < courses.length; i++) {
              final course = courses[i];

              courseBlockList.add(CourseBlock(
                width: tableCellWidth,
                height: tableCellHeight * course.classLength,
                course: course,
                index: i,
                margin: cellMargin,
                isThisWeek: Util.courseIsThisWeek(
                    course.weekOfTerm, state.currentWeek, state.maxWeekNum),
                onClick: (course) async {
                  //弹出对话框并等待其关闭
                  _showCourseDetailDialog(context, course);
                },
              ).decorateByPositioned(
                  cellMargin + tableCellWidth * (course.dayOfWeek - 1),
                  cellMargin + tableCellHeight * (course.classStart - 1)));
            }
            return Stack(children: courseBlockList);
          }),
        ));
  }

  // 弹出对话框
  Future<bool?> _showCourseDetailDialog(BuildContext context, Course course) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(8),
          content: CourseDetailWidget(
            course: course,
          ),
        );
      },
    );
  }

  /// 该课程是否需要显示
  bool _isThisWeekCourseNeedToShow(
      int weekOfTerm, int currentWeek, int maxWeekNum) {
    int offset = maxWeekNum - currentWeek;
    //判断是否未到上课时间
    if ((1 << offset) > weekOfTerm) {
      return false;
    }

    //判断课程是否已结束

    //(1 << (offset + 1) - 1
    // 快速给前offset位赋值1
    return (((1 << (offset + 1)) - 1) & weekOfTerm) > 0;
  }

  /// 计算需要显示的课程
  List<Course> _selectNeedToShowCourse(
      List<Course> courses, int currentWeek, int maxWeekNum) {
    List<Course> selectCourseList = [];

    List<bool> flag =
        List.filled(12, false); //-1表示节次没有课程,其他代表占用课程的在mCourseList中的索引

    int weekOfDay = 0; //记录周几

    int size = courses.length;

    for (int index = 0; index < size; index++) //当位置有两个及以上课程时,显示本周上的课程,其他不显示
    {
      Course course = courses[index];
      if (!_isThisWeekCourseNeedToShow(
          course.weekOfTerm, currentWeek, maxWeekNum)) {
        continue;
      }

      //Log.d("week", course.getDayOfWeek() + "");
      if (course.dayOfWeek != weekOfDay) {
        //初始化flag

        flag.fillRange(0, flag.length, false);
        weekOfDay = course.dayOfWeek;
      }

      int classStart = course.classStart;
      int classNum = course.classLength;

      int i;

      for (i = 0; i < classNum; i++) {
        if (flag[classStart + i - 1]) {
          //Log.d("action", "if");
          if (!Util.courseIsThisWeek(
              course.weekOfTerm, currentWeek, maxWeekNum)) {
            break;
          } else {
            selectCourseList.removeLast(); //删除最后一个元素
            selectCourseList.add(course);
            for (int j = 0; j < classNum; j++) {
              flag[classStart + j - 1] = true;
            }
            break;
          }
        }
      }
      if (i == classNum) {
        selectCourseList.add(course);
        for (int j = 0; j < classNum; j++) {
          flag[classStart + j - 1] = true;
        }
      }
    }
    return selectCourseList;
  }
}
