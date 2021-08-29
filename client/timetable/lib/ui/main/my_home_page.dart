import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/provider/user_provider.dart';
import 'package:light_timetable_flutter_app/ui/main/home/home_page.dart';
import 'package:light_timetable_flutter_app/ui/main/user/user_page.dart';
import 'package:light_timetable_flutter_app/utils/http_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    try {
      final resp = await HttpUtil.client.get<String>("/user/info");
      final data = HttpUtil.getDataFromResponse(resp.data);
      Util.getReadProvider<UserProvider>(context).updateLoginState(
        true,
        data["userName"],
        data["iconUrl"],
      );
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response?.statusCode == 401) {
        Navigator.pushNamed(context, "login");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        // appBar: AppBar(
        //   // Here we take the value from the MyHomePage object that was created by
        //   // the App.build method, and use it to set our appbar title.
        //   brightness: Brightness.dark,
        //   title: Text(widget.title),
        // ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "首页",
            ),
            // BottomNavigationBarItem(
            //   backgroundColor: Colors.blue,
            //   icon: Icon(Icons.message),
            //   label: "消息",
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "我的",
            ),
          ],
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (_currentIndex != index) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [HomePage(), UserPage()],
        ));
  }
}
