import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/data/values.dart';
import 'package:light_timetable_flutter_app/ui/login/login/login_page.dart';
import 'package:light_timetable_flutter_app/ui/login/register/register_page.dart';
import 'package:light_timetable_flutter_app/utils/event_bus_util.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    EventBusUtil.listen<TabSwitchEvent>(this.runtimeType.toString(), (event) {
      if (event.index >= 0 && event.index < _tabController.length) {
        _tabController.animateTo(event.index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Values.AppName),
        bottom: TabBar(controller: _tabController, tabs: [
          Tab(
            text: "登录",
          ),
          Tab(
            text: "注册",
          ),
        ]),
      ),
      body: TabBarView(controller: _tabController, children: [
        LoginPage(),
        RegisterPage(),
      ]),
    );
  }

  @override
  void dispose() {
    EventBusUtil.cancelAllByKey(this.runtimeType.toString());
    super.dispose();
  }
}

class TabSwitchEvent {
  final int index;

  TabSwitchEvent(this.index);
}
