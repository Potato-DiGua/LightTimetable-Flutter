import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/model/course.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';
import 'package:light_timetable_flutter_app/ui/editcourse/edit_course_page.dart';
import 'package:light_timetable_flutter_app/utils/dialog_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';
import 'package:provider/provider.dart';

class CourseDetailWidget extends StatelessWidget {
  final Course course;

  const CourseDetailWidget({
    required this.course,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      course.name,
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("教室: "),
                        Text(course.classRoom),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("周数: "),
                        Selector<Store, int>(
                          selector: (context, model) => model.maxWeekNum,
                          builder: (context, model, child) {
                            return Text(Util.getFormatStringFromWeekOfTerm(
                                course.weekOfTerm, model));
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("节数: "),
                        Text(
                            "${Util.getDayOfWeekString(course.dayOfWeek)} ${course.classStart}-${course.classStart + course.classLength - 1}节"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("老师: "),
                        Text(course.teacher),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Divider(
                      height: 1.0,
                    ),
                  ),
                  Container(
                    height: 48,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          /* 删除 */
                          child: TextButton(
                            onPressed: () {
                              DialogUtil.showConfirmDialog(
                                  context, "您确定要删除${course.name}吗？", () {
                                if (Provider.of<Store>(context, listen: false)
                                    .deleteCourseByCourse(course)) {
                                  Util.showToast("删除${course.name}成功");
                                } else {
                                  Util.showToast("删除${course.name}失败");
                                }
                                Navigator.pop(context);
                              });
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black)),
                          ),
                        ),
                        Expanded(
                          /* 修改 */
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return EditCoursePage(
                                  index: Store.getInstanceReadMode(context)
                                      .courses
                                      .indexOf(course),
                                  isAppended: false,
                                );
                              }));
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                  child: Icon(
                    Icons.close,
                    size: 24,
                  ),
                  onTap: () => Navigator.of(context).pop()),
            ),
          ],
        ),
      ],
    );
  }
}
