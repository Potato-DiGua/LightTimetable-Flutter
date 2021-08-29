import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';

typedef selectWeekOfTermCallBack = void Function(List<bool> checkStates);

class SelectWeekOfTerm extends StatefulWidget {
  final double height;
  final selectWeekOfTermCallBack okBtnOnClick;
  final int weekOfTerm;

  SelectWeekOfTerm(
      {required this.height,
      required this.okBtnOnClick,
      required this.weekOfTerm,
      Key? key})
      : super(key: key);

  @override
  _SelectWeekOfTermState createState() => _SelectWeekOfTermState();
}

class _SelectWeekOfTermState extends State<SelectWeekOfTerm> {
  late final List<bool> states;
  late final int maxWeekNum;

  @override
  void initState() {
    super.initState();
    maxWeekNum = Store.getInstanceReadMode(context).maxWeekNum;
    states = List.generate(maxWeekNum,
        (index) => (widget.weekOfTerm >> (maxWeekNum - index - 1)) & 0x1 == 1);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> checkBoxes = _buildCheckGroup();
    final bool isSelectAll = _isSelectAll();

    return Container(
        height: widget.height,
        child: Column(
          children: [
            Container(
              height: 48,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "取消",
                          style: TextStyle(color: Colors.black38),
                        )),
                  ),
                  Center(
                    child: Container(
                      child: Text(
                        "选择周数",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () {
                          widget.okBtnOnClick(states);
                          Navigator.of(context).pop();
                        },
                        child: Text("确定")),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        for (int i = 1; i <= states.length; i++) {
                          states[i - 1] = i % 2 == 1;
                        }
                      });
                    },
                    child: Text("单周")),
                TextButton(
                    onPressed: () {
                      setState(() {
                        for (int i = 1; i <= states.length; i++) {
                          states[i - 1] = i % 2 == 0;
                        }
                      });
                    },
                    child: Text("双周")),
                TextButton(
                    onPressed: () {
                      setState(() {
                        for (int i = 1; i <= states.length; i++) {
                          states[i - 1] = !isSelectAll;
                        }
                      });
                    },
                    child: Text(
                      "全选",
                      style: TextStyle(
                          color: isSelectAll ? Colors.black26 : Colors.blue),
                    )),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                child: Wrap(
                  children: checkBoxes,
                ),
              ),
            )
          ],
        ));
  }

  bool _isSelectAll() {
    for (bool check in states) {
      if (!check) {
        return false;
      }
    }
    return true;
  }

  static const double _checkBtnRadius = 36;

  List<Widget> _buildCheckGroup() {
    final List<Widget> checkBoxes = [];
    for (int i = 0; i < maxWeekNum; i++) {
      checkBoxes.add(Padding(
        padding: const EdgeInsets.all(6.0),
        child: GestureDetector(
            onTap: () {
              setState(() {
                states[i] = !states[i];
              });
            },
            child: Container(
                decoration: BoxDecoration(
                    color: states[i] ? Colors.blue : Colors.transparent,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(_checkBtnRadius / 2))),
                width: _checkBtnRadius,
                height: _checkBtnRadius,
                child: Center(
                    child: Text(
                  "${i + 1}",
                  style: TextStyle(
                      fontSize: 16,
                      color: states[i] ? Colors.white : Colors.black),
                )))),
      ));
    }
    return checkBoxes;
  }
}
