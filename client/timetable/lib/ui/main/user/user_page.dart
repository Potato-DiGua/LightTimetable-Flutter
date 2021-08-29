import 'package:add_calendar_event/add_calendar_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/components/card_view.dart';
import 'package:light_timetable_flutter_app/components/clipper/bottom_curve_clipper.dart';
import 'package:light_timetable_flutter_app/components/item_button.dart';
import 'package:light_timetable_flutter_app/data/values.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';
import 'package:light_timetable_flutter_app/ui/main/user/today_course.dart';
import 'package:light_timetable_flutter_app/ui/main/user/user_card.dart';
import 'package:light_timetable_flutter_app/utils/device_type.dart';
import 'package:light_timetable_flutter_app/utils/dialog_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  /// 用户信息卡片的高度
  static const double userCardHeight = UserCard.height;

  /// 内容距状态栏的高度
  static const double topMargin = 32;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: Values.bgWhite,
      child: Stack(
        children: [
          ClipPath(
            clipper: BottomCurveClipper(offset: userCardHeight / 2 + 8),
            child: Container(
              height: statusBarHeight + topMargin + userCardHeight,
              // color: Theme.of(context).primaryColor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight, //左下
                      //渐变颜色[始点颜色, 结束颜色]
                      colors: [Colors.blue.shade400, Colors.blue.shade700])),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                    EdgeInsets.fromLTRB(16, statusBarHeight + topMargin, 16, 0),
                child: UserCard(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TodayCourseView(),
              ),
              if (DeviceType.isMobile)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: _buildReminderTool(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static const _reminderEventDesc = "轻课程表自动创建";

  CardView _buildReminderTool() {
    return CardView(
      title: "提醒工具",
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            ItemButton(
              onClick: () {
                if (Store.getInstanceReadMode(context).courses.isEmpty) {
                  DialogUtil.showTipDialog(context, "请先导入课程表");
                } else {
                  _selectReminderTime();
                }
              },
              title: '导入日历',
              icon: Icon(
                Icons.calendar_today,
                color: Colors.blue.shade400,
              ),
            ),
            ItemButton(
              onClick: () {
                DialogUtil.showConfirmDialog(context, "确定要清空导入日历的所有事件吗？",
                    () async {
                  final count = await _deleteCalendarEvent();
                  Util.showToast("成功删除$count个事件");
                });
              },
              title: '清空日程',
              icon: Icon(
                Icons.delete_forever,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectReminderTime() {
    DialogUtil.showPickerViewOneColumn(
        context: context,
        title: "选择提醒时间",
        count: 30,
        builder: (index) {
          return Text(
            "${index + 1}分钟前",
            style: const TextStyle(fontSize: 16),
          );
        },
        confirmCallBack: (index) {
          _importCalendarEvent(index + 1);
        },
        initIndex: 9);
  }

  void _importCalendarEvent(int minute) async {
    DialogUtil.showLoadingDialog(context);
    try {
      await _deleteCalendarEvent();
      final store = Store.getInstanceReadMode(context);
      final times = store.classTime;
      List<Event> events = [];
      final maxWeekNum = store.maxWeekNum;

      final monday = Util.getMondayTime();
      final day = Util.getDayOfWeek();

      store.courses.forEach((course) {
        final classStart = times[course.classStart - 1];
        final classEnd = times[course.classEnd - 1];

        if (classStart.isEmpty || classEnd.isEmpty) {
          return;
        }

        int i = store.currentWeek;
        // 如果该课程在本周已经上完则不添加进日历
        if (course.dayOfWeek < day) {
          i++;
        }
        for (; i <= maxWeekNum; i++) {
          if ((course.weekOfTerm >> (maxWeekNum - i)) & 1 == 1) {
            final day = (i - store.currentWeek) * 7 + course.dayOfWeek - 1;
            events.add(Event(
                title: course.name,
                location: course.classRoom,
                description: _reminderEventDesc,
                startDate: monday.add(Duration(
                    days: day,
                    hours: classStart.start!.hour,
                    minutes: classStart.start!.minute)),
                endDate: monday.add(Duration(
                    days: day,
                    hours: classEnd.end!.hour,
                    minutes: classEnd.end!.minute)),
                alarmInterval: Duration(minutes: minute)));
          }
        }
      });
      final result = await AddCalendarEvent.addEventListToCal(events);
      Navigator.pop(context);
      Util.showToast("导入日历事件成功:$result,失败:${events.length - result}");
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }
  }

  Future<int> _deleteCalendarEvent() =>
      AddCalendarEvent.deleteCalEventByDesc(_reminderEventDesc);
}
