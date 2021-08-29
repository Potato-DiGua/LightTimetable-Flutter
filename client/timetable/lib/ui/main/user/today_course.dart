import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/model/course.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

class TodayCourseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      child: Container(
        width: double.infinity,
        height: 180,
        color: Colors.white,
        child: Stack(
          children: [
            Consumer<Store>(builder: (context, store, child) {
              final List<Course> list = [];
              final int week = Util.getDayOfWeek();
              store.courses.forEach((element) {
                if (element.dayOfWeek == week &&
                    Util.courseIsThisWeek(element.weekOfTerm, store.currentWeek,
                        store.maxWeekNum)) {
                  list.add(element);
                }
              });
              list.sort();
              if (list.isEmpty) {
                return Center(
                  child: Text("今天没有课程",
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54)),
                );
              }
              return Timeline.tileBuilder(
                padding: EdgeInsets.only(top: 24),
                scrollDirection: Axis.horizontal,
                builder: TimelineTileBuilder.fromStyle(
                  contentsAlign: ContentsAlign.basic,
                  contentsBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    child: Column(
                      children: [
                        Text(list[index].name,
                            style: const TextStyle(fontSize: 12)),
                        Text(list[index].classRoom,
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  oppositeContentsBuilder: (context, index) {
                    final course = list[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      child: Text(
                        "${course.classStart}-${course.classEnd}节",
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                  itemCount: list.length,
                ),
              );
            }),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
                child: Text(
                  "今天的课程",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
