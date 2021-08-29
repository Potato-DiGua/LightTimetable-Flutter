import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/entity/time.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';
import 'package:provider/provider.dart';

/// 节数表头
class ClassIndexTableHeader extends StatelessWidget {
  final double width;

  ClassIndexTableHeader({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      width: width,
      child: Selector<Store, List<TimeEntity>>(
        selector: (context, store) {
          return store.classTime;
        },
        builder: (context, value, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(12, (index) {
              return _classIndexBuilder(index, value);
            }),
          );
        },
      ),
    );
  }

  Widget _classIndexBuilder(int index, List<TimeEntity> classTime) {
    String time = "";
    if (index < classTime.length && !classTime[index].isEmpty) {
      final entity = classTime[index];
      return Column(
        children: [
          Text((index + 1).toString(), style: const TextStyle(fontSize: 13)),
          Text(entity.start.toString(),
              style: const TextStyle(fontSize: 10, color: Colors.black54)),
          Text(entity.end.toString(),
              style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      );
    } else {
      return Text(
        (index + 1).toString() + time,
        style: const TextStyle(fontSize: 12),
      );
    }
  }
}

/// 星期表头
class DayOfWeekTableHeader extends StatelessWidget {
  static const _dayOfWeeks = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"];

  final double height;
  final double leftPadding;

  DayOfWeekTableHeader({required this.height, required this.leftPadding});

  @override
  Widget build(BuildContext context) {
    var weeks = <Widget>[];
    var weekDay = Util.getDayOfWeek();
    for (int i = 0; i < _dayOfWeeks.length; i++) {
      Widget text;
      if (i + 1 == weekDay) {
        text = Expanded(
            child: Container(
          color: Colors.blue,
          child: Center(
            child: Text(
              _dayOfWeeks[i],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ));
      } else {
        text = Expanded(
            child: Center(
          child: Text(
            _dayOfWeeks[i],
            textAlign: TextAlign.center,
          ),
        ));
      }
      weeks.add(text);
    }

    return Container(
      height: height,
      color: Colors.black12,
      child: Row(
        children: [
          SizedBox(
            width: leftPadding,
          ),
          ...weeks
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }
}
