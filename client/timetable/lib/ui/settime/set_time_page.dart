import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/components/pickerview/picker_view.dart';
import 'package:light_timetable_flutter_app/components/pickerview/picker_view_popup.dart';
import 'package:light_timetable_flutter_app/data/values.dart';
import 'package:light_timetable_flutter_app/entity/time.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';
import 'package:light_timetable_flutter_app/utils/dialog_util.dart';

class SetTimePage extends StatefulWidget {
  @override
  _SetTimePageState createState() => _SetTimePageState();
}

class _SetTimePageState extends State<SetTimePage> {
  /// 一天的节数
  final int maxClassLength = 12;
  final List<TimeEntity> _data = [];
  final List<Time> _timeOptions = [];

  @override
  void initState() {
    super.initState();

    _data.clear();
    Store.getInstanceReadMode(context).classTime.forEach((element) {
      _data.add(element.clone());
    });
    if (_data.length > maxClassLength) {
      _data.removeRange(12, _data.length);
    } else if (_data.length < maxClassLength) {
      for (var i = _data.length; i < 12; ++i) {
        _data.add(TimeEntity());
      }
    }

    _timeOptions.clear();
    for (int i = 6; i <= 23; ++i) {
      for (int j = 0; j < 60; j += 5) {
        _timeOptions.add(Time(hour: i, minute: j));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Values.bgWhite,
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text("设置时间"),
        actions: [
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView(
      children: _buildItems(),
    );
  }

  List<Widget> _buildItems() {
    List<Widget> list = List.generate(maxClassLength, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            final time = _data[index];
            return Ink(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  _showSelectTimeDialog(time, index, setState);
                },
                onLongPress: () {
                  DialogUtil.showConfirmDialog(context, "是否要清空该时间?", () {
                    setState(() {
                      time.start = null;
                      time.end = null;
                    });
                  });
                },
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: Row(
                      children: [
                        Text("第${index + 1}节",
                            style: const TextStyle(fontSize: 16)),
                        Expanded(child: Container()),
                        ..._buildTimeWidget(time)
                      ],
                    )),
              ),
            );
          },
        ),
      );
    });

    return list;
  }

  List<Widget> _buildTimeWidget(TimeEntity? timeEntity) {
    if (timeEntity == null || timeEntity.isEmpty) {
      return [];
    } else {
      return [
        Text(timeEntity.start.toString(), style: const TextStyle(fontSize: 16)),
        Text("-", style: const TextStyle(fontSize: 16)),
        Text(timeEntity.end.toString(), style: const TextStyle(fontSize: 16)),
      ];
    }
  }

  int _getIndexFormTimeOptions(Time time) {
    return (time.hour - 6) * 12 + (time.minute / 5).floor();
  }

  void _showSelectTimeDialog(
      TimeEntity entity, int index, StateSetter setState) {
    int startRow1 = 0;
    int startRow2 = 1;
    if (!entity.isEmpty) {
      startRow1 = _getIndexFormTimeOptions(entity.start!);
      startRow2 = _getIndexFormTimeOptions(entity.end!);
    } else if (entity.isEmpty && index > 0 && !_data[index - 1].isEmpty) {
      startRow1 = _getIndexFormTimeOptions(_data[index - 1].end!) + 2;
      startRow2 = startRow1 + 9;
    }
    PickerController pickerController =
        PickerController(count: 2, selectedItems: [startRow1, startRow2]);
    PickerViewPopup.showMode(
        PickerShowMode.BottomSheet, // AlertDialog or BottomSheet
        controller: pickerController,
        context: context,
        title: Text(
          '选择时间',
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
          int index1 = pickerController.selectedRowAt(section: 0)!;
          int index2 = pickerController.selectedRowAt(section: 1)!;
          if (entity.start != _timeOptions[index1] ||
              entity.end != _timeOptions[index2]) {
            setState(() {
              entity.start = _timeOptions[index1];
              entity.end = _timeOptions[index2];
            });
          }
        },
        onSelectRowChanged: (section, row) {
          int index1 = pickerController.selectedRowAt(section: 0)!;
          int index2 = pickerController.selectedRowAt(section: 1)!;
          if (index2 < index1) {
            pickerController.animateToRow(
                min(_timeOptions.length - 1, index1 + 1),
                atSection: 1);
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
          return _timeOptions.length;
        },
        itemBuilder: (section, row) {
          return Text(
            _timeOptions[row].toString(),
            style: TextStyle(fontSize: 16),
          );
        });
  }

  void _saveAction() {
    DialogUtil.showConfirmDialog(context, "确定要保存吗?", () {
      Store.getInstanceReadMode(context).classTime = _data;
      Navigator.pop(context);
    });
  }
}
