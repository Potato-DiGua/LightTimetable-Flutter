import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/data/values.dart';
import 'package:light_timetable_flutter_app/utils/http_util.dart';
import 'package:light_timetable_flutter_app/utils/shared_preferences_util.dart';

class SelectCollegePage extends StatefulWidget {
  @override
  _SelectCollegePageState createState() => _SelectCollegePageState();
}

class _SelectCollegePageState extends State<SelectCollegePage> {
  bool _loading = true;
  final List<String> _data = [];

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 3)).then((value) {
    //   setState(() {
    //     _loading = false;
    //   });
    // });
    // _data.clear();
    // _data.add("中南大学");
    // _data.add("清华大学");
    getCollegeList();
  }

  void getCollegeList() async {
    try {
      final resp = await HttpUtil.client.get<String>("/collegeList");
      final data = HttpUtil.getDataFromResponse(resp.data);
      if (data is List) {
        setState(() {
          _loading = false;
          _data.clear();
          _data.addAll(data.cast<String>());
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Values.bgWhite,
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text("学校"),
        actions: _buildActions(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: GestureDetector(
              onTap: () {
                final name = _data[index].trim();
                print(name);
                SharedPreferencesUtil.savePreference(
                    SharedPreferencesKey.COLLEGE_NAME, name);
                Navigator.pop(context, name);
              },
              child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Row(
                    children: [
                      Text(
                        _data[index],
                        style: TextStyle(fontSize: 18),
                      ),
                      Expanded(
                          child: Text(
                        ">",
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 18),
                      ))
                    ],
                  )),
            ),
          );
        },
        itemCount: _data.length);
  }

  List<Widget> _buildActions() {
    return [];
  }
}
