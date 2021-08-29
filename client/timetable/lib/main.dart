import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';
import 'package:light_timetable_flutter_app/provider/user_provider.dart';
import 'package:light_timetable_flutter_app/ui/college/login/college_login_page.dart';
import 'package:light_timetable_flutter_app/ui/college/select/select_college_page.dart';
import 'package:light_timetable_flutter_app/ui/login/login_page.dart';
import 'package:light_timetable_flutter_app/ui/settime/set_time_page.dart';
import 'package:light_timetable_flutter_app/utils/device_type.dart';
import 'package:provider/provider.dart';

import 'ui/main/my_home_page.dart';

setBarStatus() {
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

void main() {
  if (!DeviceType.isWeb) {
    setBarStatus();
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => Store()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
  ], child: MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '小轻课程表',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(brightness: Brightness.dark),
        // textTheme: GoogleFonts.notoSansTextTheme(textTheme),
        fontFamily: DeviceType.isMobile ? null : "NotoSansSC",
      ),
      home: MyHomePage(),
      routes: {
        "login": (context) => Login(),
        "collegeLogin": (context) => CollegeLoginPage(),
        "selectCollege": (_) => SelectCollegePage(),
        "setTime": (_) => SetTimePage(),
      },
    );
  }
}
